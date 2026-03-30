import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/section_header.dart';

class FriendParkSection extends ConsumerWidget {
  const FriendParkSection({super.key, required this.friend});

  final FriendModel friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    
    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));
    final locationsAsync = ref.watch(locationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(title: isEn ? 'Eco Park' : '생태공원'),
        ),
        const SizedBox(height: 12),
        friendCharactersAsync.when(
          data: (characters) {
            final visitedSpotIds = characters
                .map((c) => int.tryParse(c.discoveredSpotId) ?? -1)
                .where((id) => id != -1)
                .toSet();

            if (visitedSpotIds.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  isEn ? 'No visited parks yet.' : '방문한 생태공원이 없습니다.',
                  style: const TextStyle(color: AppColors.gray400),
                ),
              );
            }

            return locationsAsync.when(
              data: (allLocations) {
                final uniqueMap = <int, Location>{};
                for (var loc in allLocations) {
                  if (visitedSpotIds.contains(loc.id)) {
                    uniqueMap[loc.id] = loc;
                  }
                }
                final visitedLocations = uniqueMap.values.toList();

                return SizedBox(
                  height: 140, // 200 -> 140
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: visitedLocations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final park = visitedLocations[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 130,
                            height: 86,
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: BorderRadius.circular(12),
                              image: park.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(park.imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : const DecorationImage(
                                      image: AssetImage(
                                        'assets/images/park_placeholder.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 130,
                            child: Text(
                              park.name,
                              style: AppTextStyles.subTitleM,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 130,
                            child: Text(
                              park.region,
                              style: AppTextStyles.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text(isEn ? 'Failed to load park info' : '공원 정보 로드 실패')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text(isEn ? 'Failed to load visit info' : '방문 정보 로드 실패')),
        ),
      ],
    );
  }
}
