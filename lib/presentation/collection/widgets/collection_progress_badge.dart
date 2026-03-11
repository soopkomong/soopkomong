import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class CollectionProgressBadge extends StatelessWidget {
  const CollectionProgressBadge({
    super.key,
    required this.currentCount,
    required this.totalCount,
    required this.iconPath,
  });

  final int currentCount;
  final int totalCount;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 20,
            height: 20,
            color: AppColors.primary800,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            '$currentCount/$totalCount',
            style: AppTextStyles.label.copyWith(color: AppColors.primary900),
          ),
        ],
      ),
    );
  }
}
