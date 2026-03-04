import 'package:flutter/material.dart';

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
              // 상단 핸들 (고정)
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
              // 스크롤 가능한 영역
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isDiscovered
                          ? Image.asset(
                              'assets/images/character.png',
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              'assets/images/character_silhouette.png',
                              color: Colors.grey[400],
                              fit: BoxFit.contain,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        isDiscovered ? name : '???',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDiscovered
                                  ? '$parkName에서 발견됨'
                                  : '아직 발견되지 않았습니다.',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        if (isDiscovered) ...[
                          const SizedBox(height: 4),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '발견한 날 : 2026년 2월 27일',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '캐릭터 설명',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDiscovered
                          ? '이 캐릭터는 숲의 활력을 상징하는 숲코몽입니다. 맑은 공기를 좋아하며 주로 울창한 소나무 아래에서 발견됩니다.'
                          : '아직 발견되지 않은 캐릭터입니다. 공원을 탐험하여 이 캐릭터를 찾아보세요!',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
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
