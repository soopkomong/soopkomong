import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
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
  String _searchQuery = '';

  void _onRegionChanged(Region region) {
    // 전역 selectedRegionProvider를 업데이트하여
    // filteredLocationsProvider가 자동으로 필터링합니다.
    ref.read(selectedRegionProvider.notifier).update(region);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    // 중복 제거 + 지역 필터링이 적용된 데이터를 사용합니다.
    final filteredAsync = ref.watch(filteredLocationsProvider);

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.leaf3dPng,
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'Eco Parks' : '생태 공원',
                      style: AppTextStyles.subTitleL.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 검색바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: AppColors.primary700,
                  style: AppTextStyles.body.copyWith(color: AppColors.gray900),

                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.gray50,
                    hintText: isEn ? 'Search parks...' : '검색어를 입력해주세요',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.gray500,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 18, right: 10),
                      child: Icon(
                        Icons.search,
                        color: AppColors.gray400,
                        size: 22,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 52,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RegionFilterBar(onChanged: _onRegionChanged),
              const SizedBox(height: 16),
              // 공원 리스트
              filteredAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary700),
                ),
                error: (err, stack) => Center(
                  child: Text(isEn ? 'An error occurred: $err' : '에러 발생: $err'),
                ),
                data: (allLocations) {
                  // 검색어 필터링 적용
                  final filteredLocations = _searchQuery.isEmpty
                      ? allLocations
                      : allLocations
                            .where(
                              (loc) => loc.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                  if (filteredLocations.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          isEn ? 'No parks found.' : '해당하는 공원이 없습니다.',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredLocations.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return ExploreParkCard(
                        region: Region.fromValue(
                          location.region,
                        ).getLabel(isEn),
                        name: location.name,
                        description: location.summary,
                        imageUrl: location.imageUrl,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            backgroundColor: AppColors.transparent,
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
