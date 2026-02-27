import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/explore/widgets/explore_park_card.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 상단 헤더 (중앙 정렬 해결)
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/park.png', width: 64, height: 64),
                  const SizedBox(height: 8),
                  const Text(
                    '생태 공원',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            RegionFilterBar(onChanged: (region) {}),
            const SizedBox(height: 16),
            // 공원 리스트
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  return ExploreParkCard(
                    region: '강원도',
                    name: '설악산 국립공원',
                    description:
                        '웅장한 산세와 아름다운 자연 경관을 자랑하는 대한민국의 대표적인 국립공원입니다. 다양한 등산 코스와 희귀 동식물이 서식하고 있습니다.',
                    imageUrl: 'https://picsum.photos/200/200?random=$index',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ParkDetailSheet(
                          id: '1',
                          name: '설악산 국립공원',
                          index: index,
                          isVisited: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
