import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/explore/widgets/explore_park_card.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<dynamic> _allLocations = [];
  List<dynamic> _locations = [];
  Region _selectedRegion = Region.capital;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        final matchesRegion = location['region'] == _selectedRegion.label;
        final title = (location['title'] ?? '').toString().toLowerCase();
        final matchesSearch =
            _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
        return matchesRegion && matchesSearch;
      }).toList();
    });
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
              // 상단 헤더 (중앙 정렬 해결)
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/park.png',
                      width: 64,
                      height: 64,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '생태 공원',
                      style: TextStyle(
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
                      _searchQuery = value;
                      _filterLocations();
                    },
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력해주세요',
                      hintStyle: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14,
                        height: 1.2,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 20, right: 8),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFFAAAAAA),
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 52,
                        minHeight: 48,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.only(right: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RegionFilterBar(
                onChanged: (region) {
                  setState(() {
                    _selectedRegion = region;
                    _filterLocations();
                  });
                },
              ),
              const SizedBox(height: 16),
              // 공원 리스트
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _locations.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final location = _locations[index];
                        final String id = location['id']?.toString() ?? '';
                        final String region = location['region'] ?? '';
                        final String name = location['title'] ?? '';
                        final String description = location['summary'] ?? '';
                        final String imageUrl =
                            (location['imageUrls'] as List<dynamic>?)
                                    ?.isNotEmpty ==
                                true
                            ? (location['imageUrls'] as List<dynamic>).first
                                  .toString()
                            : '';
                        final String address = location['address'] ?? '';
                        final String information =
                            location['Information'] ?? '';
                        final String tel = location['tel'] ?? '';
                        final Map<String, dynamic> navi =
                            location['navi'] ?? {};
                        final String naviLoc = navi['loc'] ?? '';
                        final double? naviLat = navi['lat'] != null
                            ? (navi['lat'] as num).toDouble()
                            : null;
                        final double? naviLng = navi['lng'] != null
                            ? (navi['lng'] as num).toDouble()
                            : null;
                        final List<String> petIds =
                            (location['petIds'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList() ??
                            [];

                        return ExploreParkCard(
                          region: region,
                          name: name,
                          description: description,
                          imageUrl: imageUrl,
                          onTap: () {
                            // JSON의 imageUrls 배열 직접 사용
                            final List<String> imgUrls =
                                (location['imageUrls'] as List<dynamic>?)
                                    ?.map((e) => e.toString())
                                    .where((url) => url.isNotEmpty)
                                    .toList() ??
                                [];

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
                                imageUrls: imgUrls,
                                address: address,
                                information: information,
                                tel: tel,
                                isVisited: true,
                                naviLoc: naviLoc,
                                naviLat: naviLat,
                                naviLng: naviLng,
                                petIds: petIds,
                              ),
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
