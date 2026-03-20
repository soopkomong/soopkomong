import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/explore/widgets/explore_park_card.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  Region _selectedRegion = Region.capital;
  String _searchQuery = '';

  void _onRegionChanged(Region region) {
    setState(() {
      _selectedRegion = region;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final locationsAsync = ref.watch(locationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // 상단 헤더
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/park.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEn ? 'Eco Parks' : '생태 공원',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 검색바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: isEn ? 'Search parks...' : '검색어를 입력해주세요',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14,
                        height: 1.2,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 20, right: 8),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFFAAAAAA),
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 52,
                        minHeight: 48,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(right: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RegionFilterBar(
                onChanged: _onRegionChanged,
              ),
              const SizedBox(height: 16),
              // 공원 리스트
              locationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text(isEn ? 'An error occurred: $err' : '에러 발생: $err')),
                data: (allLocations) {
                  final filteredLocations = allLocations.where((loc) {
                    final matchesRegion = loc.region == _selectedRegion.label;
                    final matchesSearch = _searchQuery.isEmpty ||
                        loc.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchesRegion && matchesSearch;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredLocations.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return ExploreParkCard(
                        region: Region.fromValue(location.region).getLabel(isEn),
                        name: location.name,
                        description: location.summary,
                        imageUrl: location.imageUrl,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ParkDetailSheet(
                              id: location.id.toString(),
                              name: location.name,
                              description: location.summary,
                              imageUrl: location.imageUrl,
                              imageUrls: location.imageUrls,
                              address: location.address,
                              information: location.information,
                              tel: location.tel,
                              tel1: location.tel1,
                              tel2: location.tel2,
                              isVisited: location.isVisited,
                              naviLoc: location.naviLoc,
                              naviLat: location.naviLat,
                              naviLng: location.naviLng,
                              petIds: location.petIds,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
