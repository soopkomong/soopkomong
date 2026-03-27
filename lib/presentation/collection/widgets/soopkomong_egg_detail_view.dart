import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

class SoopkomongEggDetailView extends ConsumerWidget {
  final SoopkomonTemplate template;
  final Soopkomon? soopkomon;

  const SoopkomongEggDetailView({
    super.key,
    required this.template,
    this.soopkomon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentStepsValue = soopkomon?.traveledSteps ?? 0;
    final int targetSteps = template.requiredSteps;
    final double progress = (currentStepsValue / targetSteps).clamp(0.0, 1.0);
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Column(
      children: [
        const SizedBox(height: 20),

        /// 1. 이미지 영역 (알 + 말풍선 실루엣)
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 알 이미지
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                template.eggImagePath,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            // 말풍선 실루엣
            Positioned(
              top: 0,
              right: -65,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 말풍선 몸체
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SoopkomonImage(
                          assetPath: template.actualImagePath,
                          remoteUrl: template.templateId == '000'
                              ? null
                              : template.remoteImagePath,
                          color: AppColors.black,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        /// 2. 타이틀 (공원 이름 숲코몽 알)
        Text(
          isEn
              ? '${soopkomon?.discoveredSpotName ?? 'Eco'} Soopkomong Egg'
              : '${soopkomon?.discoveredSpotName ?? '숲'} 숲코몽 알',
          style: AppTextStyles.headline.copyWith(color: AppColors.black),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        /// 3. 프로그래스 바 영역
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.87),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$currentStepsValue/$targetSteps',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        /// 4. 정보 카드 (발견 장소 + 날짜)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gray200.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.location_on_outlined,
                soopkomon?.discoveredSpotName ??
                    (isEn ? 'Undiscovered region' : '미발견 지역'),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                isEn
                    ? 'Discovered on : ${soopkomon != null ? DateFormat('EEEE, MMMM d, yyyy', 'en_US').format(soopkomon!.discoveredAt) : 'Undiscovered'}'
                    : '발견한 날짜 : ${soopkomon != null ? DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(soopkomon!.discoveredAt) : '미발견'}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.black),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black.withValues(alpha: 0.87),
            ),
          ),
        ),
      ],
    );
  }
}
