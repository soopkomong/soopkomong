import 'package:flutter/material.dart';

class RegionChip extends StatelessWidget {
  const RegionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: selected ? const Color(0xFF191919) : const Color(0xFFE6E6E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? const Color(0xFFFFFFFF) : const Color(0xFF191919),
            fontSize: 12,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
