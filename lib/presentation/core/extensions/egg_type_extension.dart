import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/soopkomon_enums.dart';

extension EggTypeUI on SoopkomonEggType {
  Color get color {
    switch (this) {
      case SoopkomonEggType.water:
        return AppColors.blue;
      case SoopkomonEggType.flying:
        return AppColors.lightBlue;
      case SoopkomonEggType.psychic:
        return AppColors.purple;
      case SoopkomonEggType.grass:
        return AppColors.green;
      case SoopkomonEggType.ground:
        return AppColors.brown;
      case SoopkomonEggType.fire:
        return AppColors.red;
      case SoopkomonEggType.tutorial:
        return AppColors.green;
    }
  }
}
