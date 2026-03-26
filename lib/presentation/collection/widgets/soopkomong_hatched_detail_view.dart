import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_shadows.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

class SoopkomongHatchedDetailView extends ConsumerWidget {
  final SoopkomonTemplate template;
  final Soopkomon? soopkomon;
  final bool isDiscovered;

  const SoopkomongHatchedDetailView({
    super.key,
    required this.template,
    this.soopkomon,
    required this.isDiscovered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: SoopkomonImage(
                  assetPath: template.actualImagePath,
                  remoteUrl: template.remoteImagePath,
                  fit: BoxFit.contain,
                  color: isDiscovered
                      ? null
                      : AppColors.black.withValues(alpha: 0.7),
                  colorBlendMode: isDiscovered ? null : BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isDiscovered ? template.name : '????',
                    style: AppTextStyles.title.copyWith(color: AppColors.black),
                  ),
                  if (isDiscovered) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 20),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (isDiscovered) ...[
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isEn ? 'Type' : '속성',
                  isEn ? template.eggType.labelEn : template.eggType.label,
                  template.eggType.iconPath,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isEn ? 'Steps walked together' : '함께 걸은 걸음',
                  '${NumberFormat('#,###').format(soopkomon?.traveledSteps ?? 0)} ${isEn ? 'steps' : '걸음'}',
                  null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 발견 장소 및 날짜 카드
          if (soopkomon != null) _buildDiscoveryCard(soopkomon!, isEn),

          const SizedBox(height: 16),
          InfoCard(
            leading: SvgPicture.asset(
              'assets/images/book.svg',
              width: 24,
              height: 24,
            ),
            title: isEn ? 'Character Description' : '캐릭터 설명',
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                template.description,
                style: AppTextStyles.label.copyWith(color: AppColors.gray900),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 발견 장소와 발견 날짜를 하나의 카드에 표시
  Widget _buildDiscoveryCard(Soopkomon soopkomon, bool isEn) {
    // 한/영 날짜 포맷 분리
    final dateText = isEn
        ? DateFormat(
            'EEEE, MMMM d, yyyy',
            'en_US',
          ).format(soopkomon.discoveredAt)
        : DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(soopkomon.discoveredAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 발견 장소 행
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/Map_pin_area.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  soopkomon.discoveredSpotName,
                  style: AppTextStyles.subTitleM.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 발견 날짜 행
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/Calendar_Check.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${isEn ? 'Discovered on' : '발견한 날짜'} :  $dateText',
                  style: AppTextStyles.label.copyWith(color: AppColors.gray900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String? iconPath) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null) ...[
                SvgPicture.asset(iconPath, width: 16, height: 16),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: AppTextStyles.subTitleM.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
