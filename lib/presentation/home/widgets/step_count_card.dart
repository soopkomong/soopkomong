import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/core/theme/app_shadows.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';

class StepCountCard extends StatelessWidget {
  final HomeState state;
  final bool isEn;

  const StepCountCard({super.key, required this.state, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(isEn ? "Today's Steps" : "오늘 걸음 수", style: AppTextStyles.label),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.footprintsSvg,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.orange,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                state.stepCount.toString(),
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
