import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_detail_sheet.dart';
import 'package:soopkomong/presentation/collection/widgets/undiscovered_character_dialog.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

class SoopkomongCard extends ConsumerStatefulWidget {
  const SoopkomongCard({
    super.key,
    required this.template,
    this.userCharacter,
    this.onTap,
  });

  final SoopkomonTemplate template;
  final Soopkomon? userCharacter;
  final VoidCallback? onTap;

  @override
  ConsumerState<SoopkomongCard> createState() => _SoopkomongCardState();
}

class _SoopkomongCardState extends ConsumerState<SoopkomongCard> {
  bool get isDiscovered => widget.userCharacter != null;
  bool get isHatched {
    if (widget.userCharacter == null) return false;
    if (widget.userCharacter!.isHatched) return true;

    // DB에는 아직 미부화 상태여도, 실시간 걸음수가 목표치에 도달했다면 부화한 것으로 표시 (UX 향상)
    final realTimeTotal = ref.watch(homeViewModelProvider).totalStepCount;
    final traveled = realTimeTotal - widget.userCharacter!.stepsAtDiscovery;
    return traveled >= widget.userCharacter!.requiredSteps;
  }

  @override
  Widget build(BuildContext context) {
    final String displayAssetPath = isHatched
        ? widget.template.actualImagePath
        : (isDiscovered
              ? widget.template.eggImagePath
              : widget.template.actualImagePath);

    // 부화 상태이거나 아예 미획득(실루엣 표시용) 상태일 때 Firebase 원격 이미지를 시도합니다.
    // 알 상태(isDiscovered && !isHatched)일 때만 원격 이미지를 사용하지 않고 로컬 알 이미지를 보여줍니다.
    final bool shouldShowRemoteCharacter = isHatched || !isDiscovered;
    final displayRemoteUrl = (shouldShowRemoteCharacter && widget.template.templateId != '000')
        ? widget.template.remoteImagePath
        : null;

    return GestureDetector(
      onTap:
          widget.onTap ??
          () async {
            if (!isDiscovered) {
              final parkTitles = await ref
                  .read(soopkomonRepositoryProvider)
                  .getParkTitlesByPetId(
                    widget.template.templateId,
                    locale: ref.read(localeProvider),
                  );

              if (context.mounted) {
                UndiscoveredCharacterDialog.show(
                  context,
                  template: widget.template,
                  availableParks: parkTitles,
                );
              }
              return;
            }

            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
              builder: (context) => SoopkomongDetailSheet(
                template: widget.template,
                soopkomon: widget.userCharacter,
                isRegionVisited: true,
                currentSteps: ref.read(homeViewModelProvider).totalStepCount,
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
                color: AppColors.gray50,
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
                        color: isDiscovered
                            ? null
                            : AppColors.black.withValues(alpha: 0.85),
                        colorBlendMode: isDiscovered
                            ? null
                            : BlendMode.srcIn,
                        errorWidget: Image.asset(
                          'assets/images/character_silhouette.png',
                          width: 80,
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
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: SvgPicture.asset(
                            widget.template.eggType.iconPath,
                            fit: BoxFit.cover,
                          ),
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
                Text(
                  widget.template.templateId,
                  style: AppTextStyles.label,
                ),
                Text(
                  isHatched ? widget.template.name : '????',
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
