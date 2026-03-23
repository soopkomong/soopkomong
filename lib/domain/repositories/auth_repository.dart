import 'package:soopkomong/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Stream<AppUser?> get userStream;
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithKakao();
  Future<AppUser?> signInWithApple();
  Future<void> signOut();
  Future<void> withdraw();
  Future<void> updateDisplayName(String name);
  AppUser? get currentUser;
}
