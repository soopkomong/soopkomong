import 'package:flutter/material.dart';

class SoopkomongCard extends StatelessWidget {
  const SoopkomongCard({
    super.key,
    required this.id,
    required this.name,
    required this.parkName,
    required this.isDiscovered,
  });

  final String id;
  final String name;
  final String parkName;
  final bool isDiscovered;

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
                  //  타입 아이콘
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
                    fontSize: 14, // 이미지처럼 강조된 폰트 크기
                    fontWeight: FontWeight.bold,
                    height: 1.1, // 줄간격 조절로 오버플로우 방지
                  ),
                ),
                Text(
                  isDiscovered ? parkName : '???',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
