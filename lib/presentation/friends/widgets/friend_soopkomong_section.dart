import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/section_header.dart';

class FriendSoopkomongSection extends ConsumerWidget {
  const FriendSoopkomongSection({super.key, required this.friend});

  final FriendModel friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));
    final visitCountAsync = ref.watch(friendVisitCountProvider(friend.id));
    final totalTemplatesAsync = ref.watch(totalTemplatesCountProvider);

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
              SectionHeader(title: isEn ? 'Soopkomong' : '얻은 숲코몽'),
              const SizedBox(width: 8),
              visitCountAsync.when(
                data: (data) => Text(
                  '${data.collectedCount}/${totalTemplatesAsync.value ?? 50}',
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
          friendCharactersAsync.when(
            data: (characters) {
              if (characters.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    isEn
                        ? 'No collected Soopkomongs yet.'
                        : '획득한 숲코몽이 없습니다.',
                    style: const TextStyle(color: AppColors.gray400),
                  ),
                );
              }
              return SizedBox(
                height: 125,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: characters.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final character = characters[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: character.isHatched
                                    ? CachedNetworkImage(
                                      imageUrl:
                                          'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/characters%2F${character.templateId}_big.png?alt=media',
                                      width: 86,
                                      height: 86,
                                      fit: BoxFit.contain,
                                      placeholder:
                                          (context, url) => const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary400,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Image.asset(
                                            character.imagePath,
                                            width: 86,
                                            height: 86,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Image.asset(
                                                   Assets.charSilhouette,
                                                  width: 86,
                                                  height: 86,
                                                  fit: BoxFit.contain,
                                                ),
                                          ),
                                    )
                                    : Image.asset(
                                      character.imagePath,
                                      width: 86,
                                      height: 86,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.egg,
                                                color: AppColors.gray300,
                                              ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          character.isHatched ? character.name : '???',
                          style: AppTextStyles.subTitleM,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, stack) => Center(
                  child: Text(isEn ? 'Failed to load data' : '데이터 로드 실패'),
                ),
          ),
        ],
      ),
    );
  }
}
