import 'package:flutter/material.dart';

/// 알의 속성 타입
enum SoopkomonEggType {
  water('물', 'Water', 'assets/images/egg/egg_water.png', Colors.blue, 'assets/images/Water.svg'),
  flying('비행', 'Flying', 'assets/images/egg/egg_fly.png', Colors.lightBlueAccent, 'assets/images/Flying.svg'),
  psychic('에스퍼', 'Psychic', 'assets/images/egg/egg_mystery.png', Colors.purpleAccent, 'assets/images/Psychic.svg'),
  grass('풀', 'Grass', 'assets/images/egg/egg_grass.png', Colors.green, 'assets/images/Grass.svg'),
  ground('땅', 'Ground', 'assets/images/egg/egg_earth.png', Colors.brown, 'assets/images/Ground.svg'),
  fire('불', 'Fire', 'assets/images/egg/egg_mystery.png', Colors.red, 'assets/images/Fire.svg');

  final String label;
  final String labelEn;
  final String imagePath;
  final String iconPath;
  final Color color;
  const SoopkomonEggType(
    this.label,
    this.labelEn,
    this.imagePath,
    this.color,
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
