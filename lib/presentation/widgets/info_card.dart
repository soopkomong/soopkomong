import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_shadows.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class InfoCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InfoCard({
    super.key,
    this.leading,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                Align(alignment: Alignment.center, child: leading),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subTitleM.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
