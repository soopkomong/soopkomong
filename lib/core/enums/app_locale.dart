enum AppLocale {
  ko('ko', '한국어'),
  en('en', 'English');

  final String code;
  final String label;

  const AppLocale(this.code, this.label);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.ko,
    );
  }
}
