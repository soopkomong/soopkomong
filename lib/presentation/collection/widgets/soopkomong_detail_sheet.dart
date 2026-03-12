import 'package:flutter/material.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_enums.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅용

class SoopkomongDetailSheet extends StatelessWidget {
  final SoopkomonTemplate template;
  final Soopkomon? soopkomon; // 유저가 획득한 경우 해당 인스턴스 데이터
  final bool isRegionVisited; // 지역 방문 (알 발견) 여부 (인스턴스가 없어도 알 상태일 수 있음)
  final int currentSteps; // 알 부화(캐릭터 발견)를 위한 현재 걸음 수

  const SoopkomongDetailSheet({
    super.key,
    required this.template,
    this.soopkomon,
    this.isRegionVisited = false,
    this.currentSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 이미 발견되었거나(soopkomon 존재), 알 상태에서 3000보를 다 채운 경우 발견으로 간주
    // (실제 서비스에서는 서버/로컬 DB 업데이트가 동반되어야 함)
    final bool finalIsDiscovered =
        soopkomon != null || (isRegionVisited && currentSteps >= 3000);
    final bool hasEgg = isRegionVisited && !finalIsDiscovered;

    // 표시할 이름
    final String displayName = (finalIsDiscovered || hasEgg)
        ? template.name
        : '???';

    // 발견 장소 이름
    final String displayParkName = soopkomon?.discoveredSpotName ?? '미발견 지역';

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      snapSizes: const [0.4, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // 상단 핸들과 닫기 버튼 (고정 영역)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 스크롤 가능한 컨텐츠 영역
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  children: [
                    const SizedBox(height: 16),

                    /// 🔹 상단 캐릭터 영역
                    Column(
                      children: [
                        // 캐릭터 이미지
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: hasEgg
                                ? Image.asset(
                                    template.eggImagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.egg, size: 80),
                                  )
                                : Image.asset(
                                    template.actualImagePath,
                                    fit: BoxFit.contain,
                                    color: finalIsDiscovered
                                        ? null
                                        : Colors.black.withValues(alpha: 0.7),
                                    colorBlendMode: finalIsDiscovered
                                        ? null
                                        : BlendMode.srcIn,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          finalIsDiscovered
                                              ? Icons.pets
                                              : Icons.help_outline,
                                          size: 80,
                                        ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// 이름 + 아이콘
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            finalIsDiscovered
                                ? const Icon(Icons.edit_outlined, size: 20)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// 🔹 캐릭터 속성 및 걸음 수 컨테이너
                    if (finalIsDiscovered) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '캐릭터 속성',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: _getEggTypeColor(
                                            template.eggType,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        template.eggType.label,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '함께 걸은 걸음 수',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${NumberFormat('#,###').format(soopkomon?.traveledSteps ?? 0)} 걸음',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (finalIsDiscovered || hasEgg)
                      InfoCard(
                        leading: const Icon(Icons.location_on_outlined),
                        title: displayParkName,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '발견한 날짜 : ${soopkomon != null ? DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(soopkomon!.discoveredAt) : '알 상태'}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                    if (finalIsDiscovered)
                      /// 🔹 카드 2 - 캐릭터 설명
                      InfoCard(
                        leading: const Icon(Icons.description_outlined),
                        title: '캐릭터 설명',
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            template.description,
                            style: const TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getEggTypeColor(SoopkomonEggType eggType) {
    switch (eggType) {
      case SoopkomonEggType.water:
        return Colors.blue;
      case SoopkomonEggType.flying:
        return Colors.lightBlueAccent;
      case SoopkomonEggType.mystic:
        return Colors.purpleAccent;
      case SoopkomonEggType.grass:
        return Colors.green;
      case SoopkomonEggType.ground:
        return Colors.brown;
    }
  }
}
