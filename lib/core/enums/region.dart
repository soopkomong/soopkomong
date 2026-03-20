enum Region {
  all('전체', 'All'),
  capital('수도권', 'Capital'),
  gangwon('강원권', 'Gangwon'),
  chungcheong('충청권', 'Chungcheong'),
  gyeongsang('경상권', 'Gyeongsang'),
  jeolla('전라권', 'Jeolla'),
  jeju('제주권', 'Jeju');

  final String koLabel;
  final String enLabel;
  const Region(this.koLabel, this.enLabel);

  String get label => koLabel; // Default to Korean for backward compatibility if needed, but we'll use a method for locale

  String getLabel(bool isEn) => isEn ? enLabel : koLabel;

  factory Region.fromValue(String value) {
    return Region.values.firstWhere(
      (e) => e.name == value || e.koLabel == value || e.enLabel == value,
      orElse: () => Region.all,
    );
  }
}
