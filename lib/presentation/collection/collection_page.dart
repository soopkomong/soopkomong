import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_progress_badge.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_sliding_tab.dart';
import 'package:soopkomong/presentation/collection/widgets/park_card.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_card.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/widgets/skeletons.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class CollectionPage extends ConsumerStatefulWidget {
  final int initialTab;
  const CollectionPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  late int _selectedTabIndex; // 0: 생태공원, 1: 숲코몽
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab;
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _selectedTabIndex = widget.initialTab;
        _pageController.jumpToPage(widget.initialTab);
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showParkDetailBottomSheet(BuildContext context, Location park) {
    // Location 엔티티의 필드 사용
    final List<String> petIds = park.petIds;
    final List<String> imageUrls = park.imageUrls;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) {
        return ParkDetailSheet(
          id: park.id.toString(),
          name: park.name,
          description: park.summary,
          imageUrl: park.imageUrl,
          imageUrls: imageUrls,
          address: park.address,
          information: park.information,
          tel: park.tel,
          tel1: park.tel1,
          tel2: park.tel2,
          isVisited: park.isVisited,
          naviLoc: park.naviLoc,
          naviLat: park.naviLat,
          naviLng: park.naviLng,
          petIds: petIds,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider 데이터 구독
    final locationsAsync = ref.watch(filteredLocationsProvider);
    final templatesAsync = ref.watch(filteredTemplatesProvider);
    final userCharactersAsync = ref.watch(userSoopkomonProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/Book_3D.png', width: 26, height: 26),
                const SizedBox(width: 6),
                Text(
                  isEn ? 'Collection' : '도감',
                  style: AppTextStyles.subTitleL.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CollectionSlidingTab(
              initialIndex: _selectedTabIndex,
              onChanged: _onTabChanged,
            ),
            const SizedBox(height: 24),
            RegionFilterBar(
              onChanged: (region) {
                ref.read(selectedRegionProvider.notifier).update(region);
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 2,
                onPageChanged: (index) {
                  if (_selectedTabIndex != index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return _buildTabPage(
                    locationsAsync,
                    userCharactersAsync,
                    templatesAsync,
                    index,
                    isEn,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPage(
    AsyncValue<List<Location>> locationsAsync,
    AsyncValue<List<Soopkomon>> userCharactersAsync,
    AsyncValue<List<SoopkomonTemplate>> templatesAsync,
    int tabIndex,
    bool isEn,
  ) {
    return CustomScrollView(
      key: PageStorageKey<String>('tab_$tabIndex'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. 진행도 배지 영역
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: _buildProgressBadge(
                locationsAsync,
                userCharactersAsync,
                templatesAsync,
                tabIndex,
              ),
            ),
          ),
        ),

        // 2. 그리드 리스트 영역
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: tabIndex == 0
              ? _buildParkSliverGrid(locationsAsync, isEn)
              : _buildCharacterSliverGrid(
                  templatesAsync,
                  userCharactersAsync,
                  isEn,
                ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildParkSliverGrid(
    AsyncValue<List<Location>> locationsAsync,
    bool isEn,
  ) {
    return locationsAsync.when(
      loading: () => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ParkCardSkeleton(),
          childCount: 6, // 6개의 스켈레톤 노출
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(
          child: Text(isEn ? 'Error occurred: $err' : '에러 발생: $err'),
        ),
      ),
      data: (locations) => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final park = locations[index];
          return ParkCard(
            park: park,
            onTap: () => _showParkDetailBottomSheet(context, park),
          );
        }, childCount: locations.length),
      ),
    );
  }

  Widget _buildCharacterSliverGrid(
    AsyncValue<List<SoopkomonTemplate>> templatesAsync,
    AsyncValue<List<Soopkomon>> userCharactersAsync,
    bool isEn,
  ) {
    return templatesAsync.when(
      loading: () => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.6,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const SoopkomongCardSkeleton(),
          childCount: 9,
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Center(
          child: Text(isEn ? 'Error occurred: $err' : '에러 발생: $err'),
        ),
      ),
      data: (templates) {
        final userCharacters = userCharactersAsync.value ?? [];

        // 최적화: 유저 캐릭터 리스트를 맵으로 변환하여 O(1) 조회 가능하게 함
        final Map<String, Soopkomon> userCharacterMap = {
          for (var char in userCharacters) char.templateId: char,
        };

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.6,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final template = templates[index];
            final userCharacter = userCharacterMap[template.templateId];

            return SoopkomongCard(
              key: ValueKey(template.templateId),
              template: template,
              userCharacter: userCharacter,
            );
          }, childCount: templates.length),
        );
      },
    );
  }

  /// 진행도 배지를 빌드하는 별도 헬퍼 (중첩 AsyncValue 가독성 개선)
  Widget _buildProgressBadge(
    AsyncValue<List<Location>> locationsAsync,
    AsyncValue<List<Soopkomon>> userCharactersAsync,
    AsyncValue<List<SoopkomonTemplate>> templatesAsync,
    int tabIndex,
  ) {
    // 모든 필요 데이터가 준비되었을 때만 계산
    if (locationsAsync.hasValue && templatesAsync.hasValue) {
      final locations = locationsAsync.value!;
      final templates = templatesAsync.value!;
      final userCharacters = userCharactersAsync.value ?? [];

      return CollectionProgressBadge(
        currentCount: tabIndex == 0
            ? locations.where((l) => l.isVisited).length
            : userCharacters.map((c) => c.templateId).toSet().length,
        totalCount: tabIndex == 0 ? locations.length : templates.length,
      );
    }

    // 로딩 중이거나 에러 발생 시 기본값 표시
    return const CollectionProgressBadge(
      currentCount: 0,
      totalCount: 0,
    );
  }
}
