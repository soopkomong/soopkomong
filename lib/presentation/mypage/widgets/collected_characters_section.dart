import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/section_header.dart';
import 'package:soopkomong/presentation/widgets/skeletons.dart';

class CollectedCharactersSection extends ConsumerWidget {
  const CollectedCharactersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final userSoopkomonsAsync = ref.watch(userSoopkomonProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          userSoopkomonsAsync.when(
            data: (characters) => SectionHeader(
              title: isEn ? 'Collected Soopkomons' : '내가 모은 숲코몽',
              count: characters.length,
              onTap: () => context.goNamed(
                AppRoute.collection.name,
                queryParameters: {'tab': '1'},
              ),
            ),
            loading: () => SectionHeader(
              title: isEn ? 'Collected Soopkomons' : '내가 모은 숲코몽',
            ),
            error: (_, _) => SectionHeader(
              title: isEn ? 'Collected Soopkomons' : '내가 모은 숲코몽',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: userSoopkomonsAsync.when(
              data: (characters) {
                if (characters.isEmpty) {
                  return _buildEmptyState(
                    isEn ? 'No characters collected yet' : '아직 모은 캐릭터가 없어요',
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: characters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _CharacterCard(character: characters[index]);
                  },
                );
              },
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => const SoopkomongCardSkeleton(),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppColors.gray500)),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Soopkomon character;

  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildCharacterImage(),
                ),
              ),

              // Positioned(
              //   top: 4,
              //   right: 4,
              //   child: Container(
              //     width: 16,
              //     height: 16,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       shape: BoxShape.circle,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          character.name,
          style: AppTextStyles.body.copyWith(color: AppColors.gray900),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCharacterImage() {
    final remoteUrl =
        'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/characters%2F${character.templateId}_big.png?alt=media';

    return CachedNetworkImage(
      imageUrl: remoteUrl,
      fit: BoxFit.contain,
      memCacheWidth: 200,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.green.shade400,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return Image.asset(
          character.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.pets, color: AppColors.gray300),
        );
      },
    );
  }
}
