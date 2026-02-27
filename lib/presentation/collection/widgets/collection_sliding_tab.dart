import 'package:flutter/material.dart';

class CollectionSlidingTab extends StatefulWidget {
  const CollectionSlidingTab({super.key});

  @override
  State<CollectionSlidingTab> createState() => _CollectionSlidingTabState();
}

class _CollectionSlidingTabState extends State<CollectionSlidingTab> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(40),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: selectedIndex == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: tabWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Row(children: [_buildTab(0, '생태공원'), _buildTab(1, '캐릭터')]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            if (selectedIndex != index) {
              setState(() {
                selectedIndex = index;
              });
            }
          },
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF191919)
                    : const Color(0xFFA3A3A3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
