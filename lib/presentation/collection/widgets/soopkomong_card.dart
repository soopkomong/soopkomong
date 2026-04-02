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
import 'package:soopkomong/presentation/widgets/shimmer_loading.dart';
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
  bool _imageLoaded = false;

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

    final displayRemoteUrl = (widget.template.templateId == '000' && !isHatched)
        ? null
        : widget.template.remoteImagePath;

    // 000번이 아니거나 부화한 경우에는 파이어 스토리지 이미지를 우선하되,
    // 000번 알 상태일 때만 로컬 에셋(egg_tuto.png)을 사용하도록 합니다.

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
                currentSteps: widget.userCharacter?.currentTotalSteps ?? 0,
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: [
                Container(
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
                                : AppColors.black.withValues(alpha: 0.7),
                            colorBlendMode: isDiscovered
                                ? null
                                : BlendMode.srcIn,
                            errorWidget: Image.asset(
                              'assets/images/character_silhouette.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            onLoaded: () {
                              if (!_imageLoaded && mounted) {
                                setState(() => _imageLoaded = true);
                              }
                            },
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
                if (!_imageLoaded)
                  Positioned.fill(
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 24,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _imageLoaded
                ? Column(
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
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(width: 40, height: 14),
                      SizedBox(height: 4),
                      ShimmerLoading(width: 80, height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
