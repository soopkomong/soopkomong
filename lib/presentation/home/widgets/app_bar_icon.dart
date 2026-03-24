import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarIcon extends StatelessWidget {
  final String svgPath;
  final VoidCallback onTap;
  final int? badgeCount;

  const AppBarIcon({
    super.key,
    required this.svgPath,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8, // 더 부드러운 그림자 (Image 2 기준)
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // SVG 아이콘
            SizedBox(
              width: 22,
              height: 22,
              child: SvgPicture.asset(
                svgPath,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Badge(
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  label: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
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
