import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';

class SoopkomongDetailSheet extends StatelessWidget {
  final String id;
  final String name;
  final String parkName;
  final bool isDiscovered;

  const SoopkomongDetailSheet({
    super.key,
    required this.id,
    required this.name,
    required this.parkName,
    required this.isDiscovered,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                          child: isDiscovered
                              ? Image.asset(
                                  'assets/images/character.png',
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
                              isDiscovered ? name : '???',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            isDiscovered
                                ? const Icon(Icons.edit_outlined, size: 20)
                                : const SizedBox.shrink(),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// 진행도 바
                        if (isDiscovered)
                          Column(
                            children: [
                              SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(
                                  value: 0.75,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),

                              const SizedBox(height: 6),
                              const Text(
                                '3000/5000',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    if (isDiscovered)
                      InfoCard(
                        leading: Icon(Icons.location_on_outlined),
                        title: '공원 이름',
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
                    if (isDiscovered)
                      /// 🔹 카드 2 - 캐릭터 설명
                      InfoCard(
                        leading: Icon(Icons.description_outlined),
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
