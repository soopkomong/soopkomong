import 'dart:ui';
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white60, // 반투명 배경 (0.6)
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 블러 효과 추가
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
        ),
      ),
    );
  }
}
