import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SectionHeader(title: isEn ? 'Soopkomong' : '숲코몽'),
        ),
        const SizedBox(height: 12),
        friendCharactersAsync.when(
          data: (characters) {
            if (characters.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  isEn ? 'No collected Soopkomongs yet.' : '획득한 숲코몽이 없습니다.',
                  style: const TextStyle(color: AppColors.gray400),
                ),
              );
            }
            return SizedBox(
              height: 125, // 130 -> 125
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: characters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
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
                                    placeholder: (context, url) =>
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary400,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) => Image
                                        .asset(
                                      character.imagePath,
                                      width: 86,
                                      height: 86,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/images/character_silhouette.png',
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
                                    errorBuilder: (context, error, stackTrace) =>
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
          error: (err, stack) => Center(child: Text(isEn ? 'Failed to load data' : '데이터 로드 실패')),
        ),
      ],
    );
  }
}
