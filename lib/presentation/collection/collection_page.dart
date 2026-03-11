import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_progress_badge.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_sliding_tab.dart';
import 'package:soopkomong/presentation/collection/widgets/park_card.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_card.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_detail_sheet.dart';

// TODO: 차후 실제 API 연동 시 전역 모델 디렉토리로 이동해야 할 열거형(Enum)
enum CharacterStatus {
  discovered, // 완전히 발견된 상태
  visitedEgg, // 방문은 했지만 미부화 상태
  undiscovered, // 아예 미발견 상태
}

class CollectionPage extends StatefulWidget {
  final int initialTab;
  const CollectionPage({super.key, this.initialTab = 0});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late int _selectedTabIndex; // 0: 생태공원, 1: 숲코몽
  List<dynamic> _allLocations = [];
  List<dynamic> _locations = [];
  Region _selectedRegion = Region.capital;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab;
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/locations.json',
      );
      final data = json.decode(response);
      setState(() {
        _allLocations = data['locations'] ?? [];
        _filterLocations();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading locations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterLocations() {
    setState(() {
      _locations = _allLocations.where((location) {
        return location['region'] == _selectedRegion.label;
      }).toList();
    });
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

              RegionFilterBar(
                onChanged: (region) {
                  setState(() {
                    _selectedRegion = region;
                    _filterLocations();
                  });
                },
              ),

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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : IndexedStack(
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
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations[index];
        final isVisited = index % 5 == 0;
        final name = location['title'] ?? '';
        final id = location['id']?.toString() ?? '';
        final description = location['summary'] ?? '';
        final imageUrl = location['imageUrl'] ?? '';
        final address = location['address'] ?? '';
        final information = location['Information'] ?? '';
        final tel = location['tel'] ?? '';

        return ParkCard(
          id: id,
          name: name,
          region: location['region'] ?? '',
          imageUrl: imageUrl,
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
                description: description,
                imageUrl: imageUrl,
                address: address,
                information: information,
                tel: tel,
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
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations[index];
        final id = location['id']?.toString() ?? '';
        final name = '숲코몽';
        final parkName = location['title'] ?? '';

        // 목업 상태 배정 로직 (3가지 상태 테스트)
        // 화면에서 세 가지 상태가 골고루 보이도록 index % 3을 활용하여 배정합니다.
        final CharacterStatus status = CharacterStatus.values[index % 3];

        final isDiscovered = status == CharacterStatus.discovered; // 발견
        final isRegionVisited = status == CharacterStatus.visitedEgg; // 지역 방문
        // TODO: 임시 데이터로 실제 데이터로 리펙토링 필요
        final currentSteps = status == CharacterStatus.visitedEgg
            ? 1578
            : 0; // 걸음 수

        return SoopkomongCard(
          id: id,
          name: name,
          parkName: parkName,
          isDiscovered: isDiscovered,
          onTap: () {
            // 모든 경우(발견, 알 상태, 미발견)에 동일한 바텀 시트를 띄우기
            // 상세 시트 내부에서 isDiscovered, isRegionVisited, currentSteps 상태에 따라 UI가 분기 처리
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
                isRegionVisited: isRegionVisited,
                currentSteps: currentSteps,
              ),
            );
          },
        );
      },
    );
  }
}
