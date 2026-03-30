import 'package:flutter/foundation.dart';
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
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_key, true);
      state = true;
      debugPrint('DEBUG: onboardingProvider.completeOnboarding() - 온보딩 완료 상태를 TRUE로 설정');
    } catch (e) {
      debugPrint('DEBUG: onboardingProvider.completeOnboarding() 실패: $e');
    }
  }

  /// 테스트 등을 위해 상태를 리셋하는 기능 (선택 사항)
  Future<void> resetOnboarding() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_key, false);
      state = false;
      debugPrint('DEBUG: onboardingProvider.resetOnboarding() - 온보딩 완료 상태를 FALSE로 리셋');
    } catch (e) {
      debugPrint('DEBUG: onboardingProvider.resetOnboarding() 실패: $e');
    }
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
