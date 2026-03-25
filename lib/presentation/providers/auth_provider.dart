import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/data/repositories/auth_repository_impl.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/repositories/auth_repository.dart';

import 'package:soopkomong/presentation/providers/step_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(prefs);
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProvider = StreamProvider<AppUser?>((ref) {
  return ref.read(authRepositoryProvider).userStream;
});

/// 인증 처리 중인지 여부를 관리하는 Notifier
class AuthLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final authLoadingProvider = NotifierProvider<AuthLoadingNotifier, bool>(
  AuthLoadingNotifier.new,
);

/// 회원 탈퇴 후 로그인 페이지에서 팝업을 보여줄지 여부를 관리하는 Notifier
class ShowWithdrawalPopupNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final showWithdrawalPopupProvider =
    NotifierProvider<ShowWithdrawalPopupNotifier, bool>(
  ShowWithdrawalPopupNotifier.new,
);
