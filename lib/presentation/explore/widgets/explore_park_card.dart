import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/widgets/shimmer_loading.dart';

class ExploreParkCard extends StatelessWidget {
  final String region;
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;

  const ExploreParkCard({
    super.key,
    required this.region,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 공원 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                width: 120,
                height: 120,
                color: AppColors.gray200,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 240,
                  memCacheHeight: 240,
                  fadeOutDuration: Duration.zero,
                  placeholderFadeInDuration: Duration.zero,
                  placeholder: (context, url) => const ShimmerLoading(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  errorWidget: (context, url, error) {
                    return const Icon(Icons.image, color: AppColors.gray500);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 공원 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.gray800,
                    ),
                    maxLines: 3,
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
