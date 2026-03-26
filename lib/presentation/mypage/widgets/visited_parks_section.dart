import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/section_header.dart';
import 'package:soopkomong/presentation/widgets/skeletons.dart';

class VisitedParksSection extends ConsumerWidget {
  const VisitedParksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final visitedLocationsAsync = ref.watch(userVisitedLocationsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          visitedLocationsAsync.when(
            data: (visitedLocations) => SectionHeader(
              title: isEn ? 'Parks Visited' : '내가 가본 생태공원',
              count: visitedLocations.length,
              onTap: () => context.goNamed(
                AppRoute.collection.name,
                queryParameters: {'tab': '0'},
              ),
            ),
            loading: () =>
                SectionHeader(title: isEn ? 'Parks Visited' : '내가 가본 생태공원'),
            error: (_, _) =>
                SectionHeader(title: isEn ? 'Parks Visited' : '내가 가본 생태공원'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 155,
            child: visitedLocationsAsync.when(
              data: (visitedLocations) {
                if (visitedLocations.isEmpty) {
                  return _buildEmptyState(
                    isEn ? 'No parks visited yet' : '아직 방문한 공원이 없어요',
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: visitedLocations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _ParkCard(location: visitedLocations[index]);
                  },
                );
              },
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => const ParkCardSkeleton(),
              ),
              error: (err, _) => _buildEmptyState('오류가 발생했습니다'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.gray500),
      ),
    );
  }
}

class _ParkCard extends StatelessWidget {
  final Location location;

  const _ParkCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.33,
              child: location.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: location.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => _buildPlaceholder(),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: AppTextStyles.body.copyWith(color: AppColors.gray900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  location.region,
                  style: AppTextStyles.label.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray200,
      child: const Center(
        child: Icon(Icons.park_outlined, color: AppColors.gray400),
      ),
    );
  }
}
