import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_progress_badge.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_sliding_tab.dart';
import 'package:soopkomong/presentation/collection/widgets/park_card.dart';
import 'package:soopkomong/presentation/collection/widgets/region_filter_bar.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_card.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';

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

  void _showParkDetailBottomSheet(BuildContext context, dynamic park) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ParkDetailSheet(
          id: (park['id'] ?? '').toString(),
          name: park['title'] ?? '',
          description: park['summary'] ?? '',
          imageUrl: park['imageUrl'] ?? '',
          address: park['address'] ?? '',
          information: park['Information'] ?? '',
          tel: park['tel'] ?? '',
          isVisited: park['isVisited'] ?? false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider 데이터 구독
    final locationsAsync = ref.watch(filteredLocationsProvider);
    final templatesAsync = ref.watch(filteredTemplatesProvider);
    final userCharacters = ref.watch(userSoopkomonProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.book, size: 40),
                    const SizedBox(height: 4),
                    const Text('도감', style: AppTextStyles.subTitleL),
                    const SizedBox(height: 24),
                    CollectionSlidingTab(
                      initialIndex: _selectedTabIndex,
                      onChanged: _onTabChanged,
                    ),
                    const SizedBox(height: 24),
                    RegionFilterBar(
                      onChanged: (region) {
                        ref
                            .read(selectedRegionProvider.notifier)
                            .update(region);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ];
          },
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (_selectedTabIndex != index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              }
            },
            children: [
              _buildTabPage(locationsAsync, userCharacters, templatesAsync, 0),
              _buildTabPage(locationsAsync, userCharacters, templatesAsync, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPage(
    AsyncValue<List<dynamic>> locationsAsync,
    List<Soopkomon> userCharacters,
    AsyncValue<List<SoopkomonTemplate>> templatesAsync,
    int tabIndex,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          locationsAsync.when(
            loading: () => const CollectionProgressBadge(
              currentCount: 0,
              totalCount: 0,
              iconPath: '',
            ),
            error: (err, stack) => const CollectionProgressBadge(
              currentCount: 0,
              totalCount: 0,
              iconPath: '',
            ),
            data: (locations) => templatesAsync.when(
              loading: () => const CollectionProgressBadge(
                currentCount: 0,
                totalCount: 0,
                iconPath: '',
              ),
              error: (err, stack) => const CollectionProgressBadge(
                currentCount: 0,
                totalCount: 0,
                iconPath: '',
              ),
              data: (templates) => CollectionProgressBadge(
                currentCount: tabIndex == 0
                    ? locations.where((l) => l['isVisited'] == true).length
                    : userCharacters.length,
                totalCount: tabIndex == 0 ? locations.length : templates.length,
                iconPath: tabIndex == 0
                    ? 'assets/images/park.png'
                    : 'assets/images/character_silhouette.png',
              ),
            ),
          ),
          const SizedBox(height: 24),
          tabIndex == 0
              ? locationsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('에러 발생: $err')),
                  data: (locations) => _buildParkGrid(locations),
                )
              : templatesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('에러 발생: $err')),
                  data: (templates) =>
                      _buildCharacterGrid(templates, userCharacters),
                ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildParkGrid(List<dynamic> locations) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final park = locations[index];
        return ParkCard(
          park: park,
          onTap: () => _showParkDetailBottomSheet(context, park),
        );
      },
    );
  }

  Widget _buildCharacterGrid(
    List<SoopkomonTemplate> templates,
    List<Soopkomon> userCharacters,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7, // 캐릭터 카드가 잘리지 않도록 높이 비율 확보
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final userCharacter = userCharacters
            .where((c) => c.templateId == template.templateId)
            .firstOrNull;

        return SoopkomongCard(template: template, userCharacter: userCharacter);
      },
    );
  }
}
