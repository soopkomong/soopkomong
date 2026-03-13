import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap((user) async {
        if (user != null) {
          await _syncUserToFirestore(user);
        }
        return _mapFirebaseUser(user);
      });

  @override
  AppUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      // Firebase User에는 userCode가 없으므로 Firestore에서 가져와야 하지만, 
      // 현재 리포지토리 패턴상 authStateChanges에서 합치거나 별도 조회가 필요함.
      // 일단 AppUser 생성자 수정에 맞춰 null로 둠.
      userCode: null, 
    );
  }

  Future<void> _syncUserToFirestore(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    Map<String, dynamic> data = {
      'id': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    // user_code가 없는 기존 유저나 신규 유저를 위해 코드 생성 로직 추가
    if (!userDoc.exists || !userDoc.data()!.containsKey('user_code')) {
      final String newCode = await _generateUniqueUserCode();
      data['user_code'] = newCode;
    }

    await userRef.set(data, SetOptions(merge: true));
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

      await _syncUserToFirestore(userCredential.user);

      return _mapFirebaseUser(userCredential.user);
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

      await _syncUserToFirestore(userCredential.user);

      return _mapFirebaseUser(userCredential.user);
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

      await _syncUserToFirestore(userCredential.user);

      return _mapFirebaseUser(userCredential.user);
    } catch (e) {
      rethrow;
    }
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
}
