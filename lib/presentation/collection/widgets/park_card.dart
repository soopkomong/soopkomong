import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class ParkCard extends StatelessWidget {
  const ParkCard({
    super.key,
    required this.id,
    required this.name,
    required this.region,
    required this.imageUrl,
    required this.isVisited,
    required this.index,
    this.onTap,
  });

  final String id;
  final String name;
  final String region;
  final String imageUrl;
  final bool isVisited;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.gray50,
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        color: isVisited ? null : Colors.grey,
                        colorBlendMode: isVisited ? null : BlendMode.saturation,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image,
                            color: AppColors.gray300,
                          );
                        },
                      ),
                    ),
                    if (!isVisited)
                      Container(color: AppColors.black.withValues(alpha: 0.35)),
                    if (!isVisited)
                      const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 40),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(color: AppColors.primary50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    region,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: AppTextStyles.subTitleM.copyWith(
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
