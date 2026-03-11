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
        return location['region'] == _selectedRegion.label;
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
              const SizedBox(height: 24),
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
                        final String imageUrl = location['imageUrl'] ?? '';
                        final String address = location['address'] ?? '';
                        final String information =
                            location['Information'] ?? '';
                        final String tel = location['tel'] ?? '';

                        return ExploreParkCard(
                          region: region,
                          name: name,
                          description: description,
                          imageUrl: imageUrl,
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
                                isVisited: true,
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
