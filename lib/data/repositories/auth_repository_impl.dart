import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/repositories/auth_repository.dart';
import 'package:soopkomong/core/services/fcm_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        final userDoc = await _syncUserToFirestore(user);
        return _mapFirebaseUser(user, userDoc);
      });

  @override
  Stream<AppUser?> get userStream => _firebaseAuth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        return user;
      }).asyncExpand((user) {
        if (user == null) return Stream.value(null);
        return _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .map((doc) => _mapFirebaseUser(user, doc));
      });

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    // 동기적으로 가져올 수 없는 Firestore 데이터는 일단 null로 처리하거나 
    // 나중에 필요한 곳에서 별도로 가져와야 함. 
    // 여기서는 기본 정보를 매핑.
    return _mapFirebaseUser(user, null);
  }

  AppUser? _mapFirebaseUser(User? user, DocumentSnapshot? doc) {
    if (user == null) return null;
    
    Map<String, dynamic>? data = doc?.data() as Map<String, dynamic>?;
    
    // 탈퇴한 유저인 경우 null 반환
    if (data?['isDeleted'] == true) return null;

    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: data?['displayName'],
      photoUrl: data?['photoUrl'] ?? user.photoURL,
      userCode: data?['user_code'],
      hasCharacter: data?['has_character'] ?? false,
      characterSettings: data?['character_settings'],
      totalSteps: data?['totalSteps'] ?? 0,
      lastStepUpdateAt: data?['lastStepUpdateAt'] != null
          ? (data?['lastStepUpdateAt'] as Timestamp).toDate()
          : null,
      createdAt: data?['createdAt'] != null
          ? (data?['createdAt'] as Timestamp).toDate()
          : null,
      deletedAt: data?['deletedAt'] != null
          ? (data?['deletedAt'] as Timestamp).toDate()
          : null,
      friends: List<String>.from(data?['friends'] ?? []),
    );
  }

  Future<DocumentSnapshot> _syncUserToFirestore(User? user) async {
    if (user == null) throw Exception('User is null');

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      // 신규 유저 초기 데이터
      final String newCode = await _generateUniqueUserCode();
      
      String? fcmToken;
      try {
        fcmToken = await FcmService.getToken();
      } catch (e) {
        log('Failed to get FCM token during signup: $e');
      }

      final data = {
        'id': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'user_code': newCode,
        'has_character': false,
        'character_settings': null,
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };
      await userRef.set(data);
      return await userRef.get();
    } else {
      // 기존 유저 로그인 시각 및 토큰 업데이트
      final Map<String, dynamic> updates = {
        'lastLoginAt': FieldValue.serverTimestamp(),
      };
      
      try {
        final token = await FcmService.getToken();
        if (token != null) {
          updates['fcmToken'] = token;
        }
      } catch (e) {
        log('Failed to get FCM token during login update: $e');
      }

      await userRef.update(updates);
      return userDoc;
    }
  }

  /// 중복되지 않는 6~8자리 사용자 코드 생성
  Future<String> _generateUniqueUserCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 헷갈리기 쉬운 I, O, 0, 1 제외
    final random = DateTime.now().microsecondsSinceEpoch;
    
    while (true) {
      // 6~8자리 랜덤 코드 생성 (단순화를 위해 일단 8자리로 고정하거나 가변적 구현)
      final String code = List.generate(8, (index) {
        final randIdx = (random + index * 31) % chars.length;
        return chars[randIdx];
      }).join();

      // 중복 확인
      final duplicate = await _firestore
          .collection('users')
          .where('user_code', isEqualTo: code)
          .limit(1)
          .get();

      if (duplicate.docs.isEmpty) {
        return code;
      }
      // 중복 시 루프를 돌며 재생성 (실제로는 정교한 난수가 필요할 수 있음)
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // 7.2.0 버전에서는 authenticate() 사용
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // accessToken은 authorizationClient를 통해 명시적으로 scope와 함께 요청해야 함
      final authz = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleUser.authentication.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final userDoc = await _syncUserToFirestore(userCredential.user);
      return _mapFirebaseUser(userCredential.user, userDoc);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> signInWithKakao() async {
    try {
      // 1. 카카오톡 설치 여부에 따라 로그인 방식 분기
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 2. idToken 유효성 확인
      final idToken = token.idToken;
      if (idToken == null) {
        throw Exception(
          '카카오 idToken을 받지 못했습니다. '
          'Kakao Developers에서 OpenID Connect가 활성화되어 있는지 확인해 주세요.',
        );
      }

      // 3. Firebase OIDC 제공업체를 통해 인증
      final provider = OAuthProvider('oidc.kakao');
      final credential = provider.credential(
        idToken: idToken,
        accessToken: token.accessToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final userDoc = await _syncUserToFirestore(userCredential.user);
      return _mapFirebaseUser(userCredential.user, userDoc);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(oauthCredential);

      final userDoc = await _syncUserToFirestore(userCredential.user);
      return _mapFirebaseUser(userCredential.user, userDoc);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    // 1. Firebase Auth 프로필 업데이트 (필요한 경우)
    await user.updateDisplayName(name);

    // 2. Firestore 유저 문서 업데이트
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': name,
    });
  }

  @override
  Future<void> signOut() async {
    // 카카오 로그아웃 시도 (카카오로 로그인하지 않았을 경우 무시)
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {
      // 카카오 로그인 상태가 아닌 경우 무시
    }
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> withdraw() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Firestore에 탈퇴 정보 마킹
    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });

    // 로그아웃 처리 (실제 Auth 계정 삭제는 14일 후 백엔드에서 처리하거나, 
    // 즉시 삭제를 원할 경우 user.delete() 호출 가능. 
    // 여기서는 14일 보존을 위해 로그아웃만 진행)
    await signOut();
  }
}
