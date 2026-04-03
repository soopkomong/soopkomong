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
import 'package:soopkomong/presentation/home/home_viewmodel.dart';

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
    final int realTimeTotalSteps = ref.watch(homeViewModelProvider).totalStepCount;
    final int currentStepsValue = (soopkomon != null)
        ? (realTimeTotalSteps - soopkomon!.stepsAtDiscovery)
            .clamp(0, double.infinity)
            .toInt()
        : 0;
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
              top: -20,
              right: -65,
              child: CustomPaint(
                painter: SpeechBubblePainter(
                  color: AppColors.white,
                  strokeColor: AppColors.gray400,
                  strokeWidth: 2.5,
                ),
                child: SizedBox(
                  width: 85,
                  height: 90,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14.0, right: 2.0),
                      child: SizedBox(
                        width: 46,
                        height: 46,
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
                ),
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

class SpeechBubblePainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  SpeechBubblePainter({
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 타원 영역 (말풍선 몸통, 원형에 가까운 비율로)
    final bubbleRect = Rect.fromLTWH(0, 0, w, h * 0.85);
    final ovalPath = Path()..addOval(bubbleRect);

    // 꼬리 영역 (직선 대신 부드러운 베지어 곡선 사용, 길이를 줄임)
    final tailPath = Path();
    tailPath.moveTo(w * 0.35, h * 0.75); // 타원의 7시 방향 안쪽
    // 꼬리 끝 지점으로 휘어지는 밖의 곡선 (꼬리를 덜 뻗어나가게 조절)
    tailPath.quadraticBezierTo(w * 0.2, h * 0.85, w * 0.1, h * 0.9);
    // 꼬리 끝에서 타원으로 돌아오는 안쪽 곡선
    tailPath.quadraticBezierTo(w * 0.15, h * 0.75, w * 0.1, h * 0.55);
    tailPath.close();

    // 몸통과 꼬리를 하나의 Path로 합침
    final bubblePath = Path.combine(PathOperation.union, ovalPath, tailPath);

    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.save();
    canvas.translate(2, 4);
    canvas.drawPath(bubblePath, shadowPaint);
    canvas.restore();

    // 채우기
    final paintFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 테두리
    final paintStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bubblePath, paintFill);
    canvas.drawPath(bubblePath, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
