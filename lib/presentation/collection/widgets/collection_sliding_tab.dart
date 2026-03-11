import 'package:flutter/material.dart';

class CollectionSlidingTab extends StatefulWidget {
  // 부모에게 인덱스를 전달할 함수를 추가합니다.
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

  // 부모로부터 initialIndex가 변경되었을 때, 내부 selectedIndex를 업데이트하기 위한 메서드
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
            child: Container(
              height: 1,
              color: const Color(0xFFE5E5E5),
            ),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50), // 이미지와 유사한 녹색
                  ),
                ),
              );
            },
          ),
          // 탭 버튼들
          Row(
            children: [
              _buildTab(0, '생태공원'),
              _buildTab(1, '숲코몽'),
            ],
          ),
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
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF191919) // 선택 시 검정
                  : const Color(0xFFA3A3A3), // 비선택 시 회색
              fontSize: 18, // 이미지에 맞춰 폰트 크기 조정
              fontWeight: FontWeight.bold, // 이미지 스타일 반영
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}
