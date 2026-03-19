import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/shimmer_loading.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/location.dart';

class ParkCard extends StatelessWidget {
  const ParkCard({super.key, required this.park, this.onTap});

  final Location park;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = park.imageUrl;
    final bool isVisited = park.isVisited;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Container(
            width: double.infinity,
            height: 117,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                colorFilter: isVisited
                                    ? null
                                    : const ColorFilter.mode(
                                        Colors.grey,
                                        BlendMode.saturation,
                                      ),
                              ),
                            ),
                          ),
                          fadeOutDuration: Duration.zero,
                          placeholderFadeInDuration: Duration.zero,
                          placeholder: (context, url) => const ShimmerLoading(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: 0,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, color: AppColors.gray300),
                        )
                      : Image.asset(
                          imageUrl.isEmpty
                              ? 'assets/images/placeholder.png'
                              : imageUrl,
                          fit: BoxFit.cover,
                          color: isVisited ? null : Colors.grey,
                          colorBlendMode: isVisited ? null : BlendMode.saturation,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, color: AppColors.gray300),
                        ),
                ),
                if (!isVisited)
                  Container(color: AppColors.black.withValues(alpha: 0.35)),
                if (!isVisited)
                  const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 32),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  park.name,
                  style: const TextStyle(
                    color: Color(0xFF123800),
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  park.region,
                  style: const TextStyle(
                    color: Color(0xFF123800),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                    letterSpacing: 0.12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
