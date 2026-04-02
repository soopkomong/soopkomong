import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class AppBarIcon extends StatelessWidget {
  final String svgPath;
  final VoidCallback onTap;
  final int? badgeCount;

  const AppBarIcon({
    super.key,
    required this.svgPath,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.gray200, width: 1),
      ),
      child: ClipOval(
        child: IconButton(
          onPressed: onTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // SVG 아이콘
              SizedBox(
                width: 22,
                height: 22,
                child: SvgPicture.asset(
                  svgPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Badge(
                    backgroundColor: AppColors.error,
                    textColor: AppColors.white,
                    label: Text(
                      '$badgeCount',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
