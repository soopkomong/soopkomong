import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

/// 미획득 캐릭터를 탭했을 때 표시되는 팝업 다이얼로그
class UndiscoveredCharacterDialog extends ConsumerWidget {
  final SoopkomonTemplate template;
  final List<String> availableParks;

  const UndiscoveredCharacterDialog({
    super.key,
    required this.template,
    required this.availableParks,
  });

  /// 팝업을 간편하게 호출하기 위한 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required SoopkomonTemplate template,
    required List<String> availableParks,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => UndiscoveredCharacterDialog(
        template: template,
        availableParks: availableParks,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 닫기 버튼
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, size: 24, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 8),

            // 캐릭터 실루엣 이미지 (동적 연동)
            SizedBox(
              width: 120,
              height: 120,
              child: SoopkomonImage(
                assetPath: template.actualImagePath,
                remoteUrl: template.remoteImagePath,
                fit: BoxFit.contain,
                color: Colors.black.withValues(alpha: 0.7),
                colorBlendMode: BlendMode.srcIn,
                errorWidget: Image.asset(
                  'assets/images/character_silhouette.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 메시지
            Text(
              isEn ? 'Not discovered yet' : '아직 만나지 못했어요',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // 발견 가능한 공원 (내용)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary50, // 연두색 배경
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    isEn ? 'Available Parks' : '발견 가능한 공원',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    availableParks.isEmpty
                        ? (isEn ? 'No info' : '정보 없음')
                        : availableParks.join(', '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
