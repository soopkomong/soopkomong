import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_progress_badge.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_sliding_tab.dart';
import 'package:soopkomong/presentation/collection/widgets/park_card.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_card.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  int _selectedTabIndex = 0; // 0: 숲코몽, 1: 생태공원

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildParkGrid(), // 0: 생태공원 탭
                    _buildCharacterGrid(), // 1: 캐릭터 탭
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
        return ParkCard(
          id: (index + 1).toString().padLeft(3, '0'),
          name: '생태 공원',
          isVisited: index % 5 == 0,
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
        return SoopkomongCard(
          id: (index + 1).toString().padLeft(3, '0'),
          name: '숲코몽',
          parkName: '--공원',
          isDiscovered: index % 5 == 0,
        );
      },
    );
  }
}
