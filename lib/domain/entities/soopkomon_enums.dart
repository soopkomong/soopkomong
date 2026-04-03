import 'package:soopkomong/core/constants/assets.dart';

/// 알의 속성 타입
enum SoopkomonEggType {
  water(
    '물',
    'Water',
    Assets.eggWater,
    Assets.water,
  ),
  flying(
    '비행',
    'Flying',
    Assets.eggFly,
    Assets.flying,
  ),
  psychic(
    '에스퍼',
    'Psychic',
    Assets.eggMystery,
    Assets.psychic,
  ),
  grass(
    '풀',
    'Grass',
    Assets.eggGrass,
    Assets.grass,
  ),
  ground(
    '땅',
    'Ground',
    Assets.eggEarth,
    Assets.ground,
  ),
  fire(
    '불',
    'Fire',
    Assets.eggMystery,
    Assets.fire,
  ),
  tutorial(
    '튜토리얼',
    'Tutorial',
    Assets.eggTuto,
    Assets.grass,
  );

  final String label;
  final String labelEn;
  final String imagePath;
  final String iconPath;

  const SoopkomonEggType(
    this.label,
    this.labelEn,
    this.imagePath,
    this.iconPath,
  );

  String getDisplayLabel(bool isEn) => isEn ? labelEn : label;

  factory SoopkomonEggType.fromValue(String value) {
    return SoopkomonEggType.values.firstWhere(
      (e) =>
          e.name == value ||
          e.label == value ||
          (value == 'mystic' && e.name == 'psychic'), // Backward compatibility
      orElse: () => SoopkomonEggType.psychic,
    );
  }
}
