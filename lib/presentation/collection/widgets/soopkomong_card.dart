import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_detail_sheet.dart';
import 'package:soopkomong/presentation/collection/widgets/undiscovered_character_dialog.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

class SoopkomongCard extends ConsumerWidget {
  const SoopkomongCard({
    super.key,
    required this.template,
    this.userCharacter,
    this.onTap,
  });

  final SoopkomonTemplate template;
  final Soopkomon? userCharacter;
  final VoidCallback? onTap;

  bool get isDiscovered => userCharacter != null;
  bool get isHatched => userCharacter?.isHatched ?? false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이미지는 부화 여부에 따라 다르게 표시
    final String displayAssetPath = isHatched
        ? template.actualImagePath
        : (isDiscovered ? template.eggImagePath : template.actualImagePath);

    // 부화 여부와 상관없이 템플릿의 원격 이미지를 시도하도록 수정
    final String? displayRemoteUrl = template.remoteImagePath;

    return GestureDetector(
      onTap:
          onTap ??
          () async {
            if (!isDiscovered) {
              final parkTitles = await ref
                  .read(locationRepositoryProvider)
                  .getParkTitlesByPetId(template.templateId);

              if (context.mounted) {
                UndiscoveredCharacterDialog.show(
                  context,
                  template: template,
                  availableParks: parkTitles,
                );
              }
              return;
            }

            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SoopkomongDetailSheet(
                template: template,
                soopkomon: userCharacter,
                isRegionVisited: true,
                currentSteps: userCharacter?.currentTotalSteps ?? 0,
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SoopkomonImage(
                        assetPath: displayAssetPath,
                        remoteUrl: displayRemoteUrl,
                        fit: BoxFit.contain,
                        color: isHatched || !isDiscovered
                            ? (isDiscovered
                                ? null
                                : Colors.black.withValues(alpha: 0.7))
                            : null, // 획득했지만 미부화인 경우(알)는 컬러 유지
                        colorBlendMode:
                            isHatched || !isDiscovered
                                ? (isDiscovered ? null : BlendMode.srcIn)
                                : null,
                        errorWidget: Image.asset(
                          'assets/images/character_silhouette.png',
                          width: 80, // 40 -> 80으로 확대
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (isDiscovered)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFAFAFAF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.templateId, style: AppTextStyles.label),
                Text(
                  isHatched ? template.name : '????',
                  style: AppTextStyles.subTitleL,
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
