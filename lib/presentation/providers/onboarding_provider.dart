import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soopkomong/presentation/providers/common_providers.dart';

class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'has_seen_onboarding';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
    state = true;
  }
  
  /// 테스트 등을 위해 상태를 리셋하는 기능 (선택 사항)
  Future<void> resetOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, false);
    state = false;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
