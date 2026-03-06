import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';

class SoopkomongDetailSheet extends StatelessWidget {
  final String id;
  final String name;
  final String parkName;
  final bool isDiscovered; // 기존 발견 여부
  final bool isRegionVisited; // 지역 방문 (알 발견) 여부
  final int currentSteps; // 알 부화(캐릭터 발견)를 위한 현재 걸음 수

  const SoopkomongDetailSheet({
    super.key,
    required this.id,
    required this.name,
    required this.parkName,
    required this.isDiscovered,
    this.isRegionVisited = false,
    this.currentSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 3000보를 걸으면 캐릭터를 발견 처리 (또는 기존에 이미 발견된 경우)
    final bool finalIsDiscovered =
        isDiscovered || (isRegionVisited && currentSteps >= 3000);
    // 지역은 방문하여 알을 찾았지만 아직 3000보를 다 걷지 못한 상태
    final bool hasEgg = isRegionVisited && !finalIsDiscovered;

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
                          height: 137,
                          child: finalIsDiscovered
                              ? Image.asset(
                                  'assets/images/character.png',
                                  fit: BoxFit.contain,
                                )
                              : hasEgg
                              ? Image.asset(
                                  'assets/images/vector.png',
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  'assets/images/character_silhouette.png',
                                  fit: BoxFit.contain,
                                ),
                        ),

                        const SizedBox(height: 28),

                        /// 이름 + 아이콘
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (finalIsDiscovered || hasEgg) ? name : '???',
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
                                          color: Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '불',
                                        style: TextStyle(
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
                                children: const [
                                  Text(
                                    '함께 걸은 걸음 수',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '5,678 걸음',
                                    style: TextStyle(
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
                        title: parkName, // 기존 '공원 이름' 텍스트 대신 변수 사용
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16),
                                SizedBox(width: 4),
                                Text('발견한 날짜 : 2025년 3월 3일 월요일'),
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
                        child: const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Lorem ipsum dolor sit amet consectetur. Elit ornare rhoncus morbi quis egestas sed leo. Congue amet semper nec tempus ac sagittis posuere urna libero. Aliquam lectus neque massa urna.',
                            style: TextStyle(fontSize: 13, height: 1.5),
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
}
