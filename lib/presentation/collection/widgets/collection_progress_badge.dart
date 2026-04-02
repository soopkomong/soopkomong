import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

enum CollectionBadgeType { park, soopkomong }

class CollectionProgressBadge extends StatelessWidget {
  const CollectionProgressBadge({
    super.key,
    required this.currentCount,
    required this.totalCount,
    required this.type,
  });

  final int currentCount;
  final int totalCount;
  final CollectionBadgeType type;

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
          if (type == CollectionBadgeType.park)
            SvgPicture.asset('assets/images/Leaf.svg', width: 24, height: 24)
          else
            Image.asset('assets/images/Sprout.png', width: 24, height: 24),
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
