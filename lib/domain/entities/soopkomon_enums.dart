/// 알의 속성 타입
enum SoopkomonEggType {
  water('물', 'assets/images/characters/egg_water.png'),
  flying('비행', 'assets/images/characters/egg_fly.png'),
  mystic('신비', 'assets/images/characters/egg_mystery.png'),
  grass('풀', 'assets/images/characters/egg_grass.png'),
  ground('땅', 'assets/images/characters/egg_earth.png');

  final String label;
  final String imagePath;
  const SoopkomonEggType(this.label, this.imagePath);

  factory SoopkomonEggType.fromValue(String value) {
    return SoopkomonEggType.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => SoopkomonEggType.mystic,
    );
  }
}
