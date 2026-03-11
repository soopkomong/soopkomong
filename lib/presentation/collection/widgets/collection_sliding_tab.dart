import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class CollectionSlidingTab extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int initialIndex;

  const CollectionSlidingTab({
    super.key,
    required this.onChanged,
    this.initialIndex = 0,
  });

  @override
  State<CollectionSlidingTab> createState() => _CollectionSlidingTabState();
}

class _CollectionSlidingTabState extends State<CollectionSlidingTab> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant CollectionSlidingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          // 전체 바닥 회색 라인
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: AppColors.gray200),
          ),
          // 선택된 탭의 녹색 표시기 라인
          LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 2;
              return AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: selectedIndex == 0
                    ? Alignment.bottomLeft
                    : Alignment.bottomRight,
                child: Container(
                  width: tabWidth,
                  height: 3,
                  decoration: const BoxDecoration(color: AppColors.primary700),
                ),
              );
            },
          ),
          // 탭 버튼들
          Row(children: [_buildTab(0, '생태공원'), _buildTab(1, '숲코몽')]),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selectedIndex != index) {
            setState(() {
              selectedIndex = index;
            });
            widget.onChanged(index);
          }
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyles.subTitleL.copyWith(
              color: isSelected
                  ? AppColors
                        .black // 선택 시 검정
                  : AppColors.gray200, // 비선택 시 회색
            ),
          ),
        ),
      ),
    );
  }
}
