import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapFirebaseUser);

  @override
  AppUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
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
