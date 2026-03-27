import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class CollectionProgressBadge extends StatelessWidget {
  const CollectionProgressBadge({
    super.key,
    required this.currentCount,
    required this.totalCount,
  });

  final int currentCount;
  final int totalCount;

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
          SvgPicture.asset('assets/images/Leaf.svg', width: 24, height: 24),
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
