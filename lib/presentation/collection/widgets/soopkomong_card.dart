import 'package:flutter/material.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_detail_sheet.dart';

class SoopkomongCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SoopkomongDetailSheet(
                template: template,
                soopkomon: userCharacter,
                isRegionVisited: true, // TODO: 실제 데이터 연동
                currentSteps: userCharacter?.currentTotalSteps ?? 0,
              ),
            );
          },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFEBEBEB),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          template.actualImagePath,
                          fit: BoxFit.contain,
                          color: isDiscovered
                              ? null
                              : Colors.black.withValues(alpha: 0.7),
                          colorBlendMode: isDiscovered ? null : BlendMode.srcIn,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/character_silhouette.png',
                                width: 40,
                                height: 40,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    template.templateId,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  if (isDiscovered) ...[
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    // 미발견 시 빈 공간을 채워 높이 유지
                    const SizedBox(height: 16), // name 영역 placeholder
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
