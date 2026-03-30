import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/router/app_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/widgets/url_avatar.dart';

class FriendListItem extends ConsumerWidget {
  const FriendListItem({super.key, required this.friend});

  final FriendModel friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    
    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));

    return InkWell(
      onTap: () {
        context.pushNamed(AppRoute.friendProfile.name, extra: friend);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            UrlAvatar(photoUrl: friend.photoUrl ?? '', size: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: AppTextStyles.subTitleL.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  friendCharactersAsync.when(
                    data: (characters) {
                      final visitedCount = characters
                          .map((c) => c.discoveredSpotId)
                          .where((id) => id.isNotEmpty)
                          .toSet()
                          .length;
                      final collectedCount = characters.length;

                      final totalLocationsAsync = ref.watch(
                        totalLocationsCountProvider,
                      );
                      final totalTemplatesAsync = ref.watch(
                        totalTemplatesCountProvider,
                      );

                      final leafMax = totalLocationsAsync.value ?? 49;
                      final pawMax = totalTemplatesAsync.value ?? 50;

                      return Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/Leaf.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$visitedCount/$leafMax',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/Sprout.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$collectedCount/$pawMax',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(height: 14),
                    error: (err, stack) => Text(
                      isEn ? 'Failed to load data' : '데이터 로드 실패',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.error,
                      ),
                    ),
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
