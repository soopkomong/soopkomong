import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/core/enums/app_locale.dart';

class LocaleNotifier extends Notifier<AppLocale> {
  static const _storageKey = 'app_locale_code';

  @override
  AppLocale build() {
    // 초기 부팅 시에는 기본값(ko)을 반환하고,
    // 실제 저장된 값은 AppInitializer나 별도 초기화 로직에서 동기적으로 로드하거나
    // 아래처럼 비동기로 처리할 수 있습니다.
    // 여기서는 간단하게 기본 ko를 사용하고 초기화 시점에 업데이트하도록 합니다.
    return AppLocale.ko;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code != null) {
      state = AppLocale.fromCode(code);
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);
