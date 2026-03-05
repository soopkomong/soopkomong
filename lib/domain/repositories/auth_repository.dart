import 'package:soopkomong/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithKakao();
  Future<AppUser?> signInWithApple();
  Future<void> signOut();
  AppUser? get currentUser;
}
