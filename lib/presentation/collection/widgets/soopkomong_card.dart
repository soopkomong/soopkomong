import 'package:flutter/material.dart';

class SoopkomongCard extends StatelessWidget {
  const SoopkomongCard({
    super.key,
    required this.id,
    required this.name,
    required this.parkName,
    required this.isDiscovered,
    this.onTap,
  });

  final String id;
  final String name;
  final String parkName;
  final bool isDiscovered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: SizedBox(
                height: 50, // 👈 높이 고정 (조절 가능)
                child: isDiscovered
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            id,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            parkName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          id,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
