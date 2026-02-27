import 'package:soopkomong/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
  AppUser? get currentUser;
}
