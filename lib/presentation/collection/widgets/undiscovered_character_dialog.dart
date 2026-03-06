import 'package:flutter/material.dart';

/// 미획득 캐릭터를 탭했을 때 표시되는 팝업 다이얼로그
class UndiscoveredCharacterDialog extends StatelessWidget {
  final List<String> availableParks;

  const UndiscoveredCharacterDialog({super.key, required this.availableParks});

  /// 팝업을 간편하게 호출하기 위한 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required List<String> availableParks,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) =>
          UndiscoveredCharacterDialog(availableParks: availableParks),
    );
  }

  @override
  Widget build(BuildContext context) {
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

            // 캐릭터 실루엣 이미지
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/images/character_silhouette.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // 메시지
            const Text(
              '아직 만나지 못했어요',
              style: TextStyle(
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
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '발견 가능한 공원',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    availableParks.join(', '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
