import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final VoidCallback? onTap;

  const SectionHeader({super.key, required this.title, this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.subTitleL.copyWith(color: AppColors.gray900),
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: AppTextStyles.subTitleL.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }
}
