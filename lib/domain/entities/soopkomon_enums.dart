import 'package:flutter/material.dart';

/// 알의 속성 타입
enum SoopkomonEggType {
  water('물', 'Water', 'assets/images/egg/egg_water.png', Colors.blue),
  flying('비행', 'Flying', 'assets/images/egg/egg_fly.png', Colors.lightBlueAccent),
  mystic('신비', 'Mystic', 'assets/images/egg/egg_mystery.png', Colors.purpleAccent),
  grass('풀', 'Grass', 'assets/images/egg/egg_grass.png', Colors.green),
  ground('땅', 'Ground', 'assets/images/egg/egg_earth.png', Colors.brown);

  final String label;
  final String labelEn;
  final String imagePath;
  final Color color;
  const SoopkomonEggType(this.label, this.labelEn, this.imagePath, this.color);

  String getDisplayLabel(bool isEn) => isEn ? labelEn : label;

  factory SoopkomonEggType.fromValue(String value) {
    return SoopkomonEggType.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => SoopkomonEggType.mystic,
    );
  }
}
