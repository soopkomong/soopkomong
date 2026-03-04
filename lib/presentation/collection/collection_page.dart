import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_progress_badge.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_sliding_tab.dart';
import 'package:soopkomong/presentation/collection/widgets/park_card.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_card.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_detail_sheet.dart';
import 'package:soopkomong/presentation/collection/widgets/undiscovered_character_dialog.dart';

class CollectionPage extends StatefulWidget {
  final int initialTab;
  const CollectionPage({super.key, this.initialTab = 0});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late int _selectedTabIndex; // 0: 생태공원, 1: 숲코몽

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab;
  }

  // 부모로부터 initialIndex가 변경되었을 때, 내부 selectedIndex를 업데이트하기 위한 메서드
  @override
  void didUpdateWidget(covariant CollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _selectedTabIndex = widget.initialTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              const Icon(Icons.book, size: 55),
              const Text(
                '도감',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: 230,
                child: CollectionSlidingTab(
                  initialIndex: _selectedTabIndex,
                  onChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              RegionFilterBar(onChanged: (region) {}),

              const SizedBox(height: 24),

              CollectionProgressBadge(
                currentCount: _selectedTabIndex == 0 ? 3 : 6, // 임시 데이터
                totalCount: _selectedTabIndex == 0 ? 20 : 50, // 임시 데이터
                iconPath: _selectedTabIndex == 0
                    ? 'assets/images/park.png'
                    : 'assets/images/character_silhouette.png',
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [_buildParkGrid(), _buildCharacterGrid()],
                ),
              ),
              const SizedBox(height: 100), // 바텀 네비게이션 바 고려한 여백 추가
            ],
          ),
        ),
      ),
    );
  }

  // 공원
  Widget _buildParkGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7, // 카드가 세로로 더 긴 비율을 갖도록 설정
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final isVisited = index % 5 == 0;
        final name = '서울숲공원';
        final id = (index + 1).toString().padLeft(3, '0');

        return ParkCard(
          id: id,
          name: name,
          isVisited: isVisited,
          index: index,
          onTap: () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ParkDetailSheet(
                id: id,
                name: name,
                index: index,
                isVisited: isVisited,
              ),
            );
          },
        );
      },
    );
  }

  // 숲코몽
  Widget _buildCharacterGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7, // 카드가 세로로 더 긴 비율을 갖도록 설정
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final id = (index + 1).toString().padLeft(3, '0');
        final name = '숲코몽';
        final parkName = '서울숲공원';
        final isDiscovered = index % 5 == 0;

        return SoopkomongCard(
          id: id,
          name: name,
          parkName: parkName,
          isDiscovered: isDiscovered,
          onTap: () {
            if (isDiscovered) {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SoopkomongDetailSheet(
                  id: id,
                  name: name,
                  parkName: parkName,
                  isDiscovered: isDiscovered,
                ),
              );
            } else {
              UndiscoveredCharacterDialog.show(
                context,
                availableParks: ['공원이름'], // TODO: 실제 데이터로 교체
              );
            }
          },
        );
      },
    );
  }
}
