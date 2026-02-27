import 'package:flutter/material.dart';

class ParkCard extends StatelessWidget {
  const ParkCard({
    super.key,
    required this.id,
    required this.name,
    required this.isVisited,
    required this.index,
    this.onTap,
  });

  final String id;
  final String name;
  final bool isVisited;
  final int index;
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
                      child: Image.network(
                        'https://picsum.photos/500/500?random=$index',
                        fit: BoxFit.cover,
                        color: isVisited ? null : Colors.grey,
                        colorBlendMode: isVisited ? null : BlendMode.saturation,
                      ),
                    ),
                    if (!isVisited)
                      Container(color: Colors.black.withValues(alpha: 0.35)),
                    if (!isVisited)
                      const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 40),
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
                    '수도권',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      overflow: TextOverflow.ellipsis,
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
