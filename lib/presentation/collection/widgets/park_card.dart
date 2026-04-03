import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/shimmer_loading.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParkCard extends ConsumerWidget {
  const ParkCard({super.key, required this.park, this.onTap});

  final Location park;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;
    final regionLabel = Region.fromValue(park.region).getLabel(isEn);
    final String imageUrl = park.imageUrl;
    final bool isVisited = park.isVisited;

    return GestureDetector(
      onTap: () {
        if (imageUrl.startsWith('http')) {
          // 상세 화면 진입 전 이미지 프리캐싱
          precacheImage(CachedNetworkImageProvider(imageUrl), context);
        }
        onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: AppColors.white,
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
                            memCacheWidth: 400,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: isVisited
                                      ? null
                                      : const ColorFilter.mode(
                                          AppColors.gray500,
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
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              color: AppColors.gray300,
                            ),
                          )
                        : Image.asset(
                            imageUrl.isEmpty
                                ? 'assets/images/placeholder.png'
                                : imageUrl,
                            fit: BoxFit.cover,
                            color: isVisited ? null : AppColors.grey,
                            colorBlendMode: isVisited
                                ? null
                                : BlendMode.saturation,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image,
                                  color: AppColors.gray300,
                                ),
                          ),
                  ),
                  if (!isVisited)
                    Container(color: AppColors.black.withValues(alpha: 0.35)),
                  if (!isVisited)
                    const Center(
                      child: Icon(Icons.lock, color: AppColors.white, size: 32),
                    ),
                ],
              ),
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
                  style: AppTextStyles.subTitleL.copyWith(
                    color: AppColors.primary900,
                    height: 1.50,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  regionLabel,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary900,
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
