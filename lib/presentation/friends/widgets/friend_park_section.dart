import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';
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

    final visitedLocationsAsync = ref.watch(
      friendVisitedLocationsProvider(friend.id),
    );
    final visitCountAsync = ref.watch(friendVisitCountProvider(friend.id));
    final totalLocationsAsync = ref.watch(totalLocationsCountProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SectionHeader(title: isEn ? 'Eco Park' : '가 본 생태공원'),
              const SizedBox(width: 8),
              visitCountAsync.when(
                data: (data) => Text(
                  '${data.visitedCount}/${totalLocationsAsync.value ?? 49}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          visitedLocationsAsync.when(
            data: (visitedLocations) {
              if (visitedLocations.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    isEn ? 'No visited parks yet.' : '방문한 생태공원이 없습니다.',
                    style: const TextStyle(color: AppColors.gray400),
                  ),
                );
              }

              return SizedBox(
                height: 140,
                child: ListView.separated(
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
            error: (err, stack) => Center(
              child: Text(isEn ? 'Failed to load park info' : '공원 정보 로드 실패'),
            ),
          ),
        ],
      ),
    );
  }
}
