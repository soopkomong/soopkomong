import 'package:flutter/material.dart';

class ParkCard extends StatelessWidget {
  const ParkCard({
    super.key,
    required this.id,
    required this.name,
    required this.isVisited,
  });

  final String id;
  final String name;
  final bool isVisited;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    // TODO: 생태공원 전용 이미지나 플레이스홀더로 교체 필요
                    child: isVisited
                        ? const Icon(Icons.park, size: 50, color: Colors.green)
                        : const Icon(Icons.park, size: 50, color: Colors.grey),
                  ),
                  // 방문 완료(스탬프 등) 아이콘 처리
                  if (isVisited)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  id,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14, // 강조된 폰트 크기
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
