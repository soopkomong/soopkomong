import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/mypage/character_page/widgets/character_create_popup.dart';
import 'package:soopkomong/presentation/widgets/character_parts_avatar.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soopkomong/presentation/providers/character_parts_provider.dart';
import 'package:soopkomong/presentation/providers/character_provider.dart';
import 'package:soopkomong/core/utils/app_toast.dart';

import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
// import 'package:soopkomong/domain/entities/soopkomon.dart'; // 튜토리얼 구현 시 활성화

class CharacterCustomizePage extends ConsumerStatefulWidget {
  const CharacterCustomizePage({super.key});

  @override
  ConsumerState<CharacterCustomizePage> createState() =>
      _CharacterCustomizePageState();
}

class _CharacterCustomizePageState extends ConsumerState<CharacterCustomizePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _globalKey = GlobalKey(); // 캡쳐를 위한 키
  bool _isSaving = false; // 저장 중 로딩 상태
  bool _isInitialLoading = true; // 초기 에셋 로딩 상태

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const List<String> _categoriesKo = ['머리', '얼굴', '옷'];
  static const List<String> _categoriesEn = ['Hair', 'Face', 'Clothes'];

  // 선택된 파츠 상태
  String _selectedHair = '01';
  String _selectedFace = 'smile';
  String _selectedClothes = '01'; // '01'은 의상 없음을 의미
  // 신발은 탭에서는 빠졌지만 아바타에 넘겨야 하므로 기본값 유지
  String? _selectedShoes; // 기본적으로 신발 안 신음 (null)

  // 선택된 색상 상태 (선택된 카테고리에 따라 적용됨)
  Color _selectedSkinColor = const Color(0xFFFFDAB9); // 기본 피부색 (Light Peach)
  Color _selectedHairColor = Colors.white;
  Color _selectedClothesColor = Colors.white;
  Color _selectedShoesColor = Colors.white;

  final List<Color> _palette = [
    const Color(0xFF1A1A1A), // 1. 모던 블랙
    const Color(0xFF4E342E), // 2. 리치 브라운
    const Color(0xFF8D6E63), // 3. 웜 체스넛
    const Color(0xFFFFD54F), // 4. 골든 블론드
    const Color(0xFFF5F5F5), // 5. 실버 화이트
    const Color(0xFFFF8A80), // 6. 소프트 레드
    const Color(0xFFF06292), // 7. 소프트 핑크
    const Color(0xFFFFB74D), // 8. 소프트 오렌지
    const Color(0xFF81C784), // 9. 소프트 그린
    const Color(0xFF64B5F6), // 10. 소프트 블루
    const Color(0xFFBA68C8), // 11. 소프트 퍼플
  ];

  //피부 팔레트 (전체적으로 맑고 밝은 톤, 눈코입을 가리지 않기 위해 어두운 톤 지양)
  final List<Color> _skinPalette = [
    const Color(0xFFFFFFFF), // 1. 화이트
    const Color(0xFFFFD8C1), // 2. 생기 있는 페일 피치
    const Color(0xFFFFCBA4), // 3. 화사한 애프리콧
    const Color(0xFFFFB07C), // 4. 건강한 라이트 피치
    const Color(0xFFE89F6B), // 5. 생동감 있는 골든 샌드
    const Color(0xFFC68642), // 6. 활력 있는 탠(Tan)
    const Color(0xFFA6643B), // 7. 깊이 있는 브론즈 (가시성 개선)
    const Color(0xFFE8F5E9), // 9. 파스텔 그린 (민트 티)
    const Color(0xFFC8E6C9), // 10. 연한 초록 (애플 그린)
    const Color(0xFFE3F2FD), // 11. 파스텔 블루 (스카이 아이스)
    const Color(0xFFBBDEFB), // 12. 연한 파랑 (베이비 블루)
    const Color(0xFFF3E5F5), // 13. 파스텔 퍼플 (라벤더)
    const Color(0xFFE1BEE7), // 14. 연한 보라 (라이트 바이올렛)
    const Color(0xFFFCE4EC), // 15. 파스텔 핑크 (코튼 캔디)
    const Color(0xFFF8BBD0), // 16. 연한 핑크 (버블검)
  ];

  @override
  void initState() {
    super.initState();
    final categories = ref.read(localeProvider) == AppLocale.en
        ? _categoriesEn
        : _categoriesKo;
    _tabController = TabController(length: categories.length, vsync: this);

    // 1. 기존 캐릭터 데이터 로드
    final user = ref.read(userProvider).value;
    if (user != null && user.characterSettings != null) {
      final settings = user.characterSettings!;
      _selectedHair = settings['hair'] ?? '01';
      _selectedFace = settings['face'] ?? 'smile';
      // 의상 설정 로드 ('01'은 의상 없음으로 정상 처리)
      _selectedClothes = settings['clothes'] ?? '01';
      _selectedShoes = settings['shoes'];
      _selectedSkinColor = Color(settings['skinColor'] as int);
      _selectedHairColor = Color(settings['hairColor'] as int);
      _selectedClothesColor = Color(settings['clothesColor'] as int);
      _selectedShoesColor = Color(settings['shoesColor'] as int? ?? 0xFFFFFFFF);
    }

    // 2. 캐릭터가 없는 경우에만 환영 팝업 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null || !user.hasCharacter) {
        showDialog(
          context: context,
          builder: (context) => const CharacterCreatePopup(),
        );
      }
    });

    _tabController.addListener(() {
      setState(() {}); // 탭 바뀔 때마다 색상 팔레트 UI 갱신을 위해
    });

    // 3. 에셋 사전 로드 시작
    _preloadAssets();
  }

  /// 모든 필수 에셋을 사전에 로드
  Future<void> _preloadAssets() async {
    try {
      // 1. 캐릭터 파츠 데이터 로딩 대기
      final parts = await ref.read(characterPartsProvider.future);

      if (!mounted) return;

      // 2. 모든 이미지 URL 생성 및 프리캐시
      // 기본 몸체
      final List<String> allAssetPaths = ['body_base.png', 'body_shadow.png'];

      // 머리카락 (각 ID별로 메인, 하이라이트, 그림자 포함)
      final List<String> hairs = parts['hairs'] ?? [];
      for (final id in hairs) {
        allAssetPaths.addAll([
          'hair_$id.png',
          'hair_${id}_highlight.png',
          'hair_${id}_shadow.png',
          'hair_${id}_sub_shadow.png',
        ]);
      }

      // 얼굴
      final List<String> faces = parts['faces'] ?? [];
      for (final id in faces) {
        allAssetPaths.add('face_$id.png');
      }

      // 의상
      final List<String> clothes = parts['clothes'] ?? [];
      for (final id in clothes) {
        allAssetPaths.add('clothes_$id.png');
      }

      // 신발
      final List<String> shoes = parts['shoes'] ?? [];
      for (final id in shoes) {
        allAssetPaths.add('shoes_$id.png');
      }

      // Storage URL로 변환하여 precacheImage 실행
      const storageBaseUrl =
          'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/';

      final List<Future<void>> imageFutures = allAssetPaths.map((assetPath) {
        final fileName = assetPath.split('/').last;
        final imageUrl = '${storageBaseUrl}parts%2F$fileName?alt=media';
        return precacheImage(CachedNetworkImageProvider(imageUrl), context);
      }).toList();

      // 3. 모든 에셋 로딩 대기
      await Future.wait(imageFutures);
    } catch (e) {
      debugPrint('에셋 사전 로드 중 오류 발생: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  void _randomizeCharacter(Map<String, List<String>> parts) {
    setState(() {
      final hairs = parts['hairs'] ?? ['01'];
      final clothes = parts['clothes'] ?? ['01'];
      final shoes = parts['shoes'] ?? [];

      _selectedHair = (hairs.toList()..shuffle()).first;
      _selectedClothes = (clothes.toList()..shuffle()).first;
      // 신발 리스트가 비어있지 않을 때만 랜덤 선택
      if (shoes.isNotEmpty) {
        _selectedShoes = (shoes.toList()..shuffle()).first;
      }
      _selectedHairColor = (_palette.toList()..shuffle()).first;
      _selectedSkinColor = (_skinPalette.toList()..shuffle()).first;
    });
  }

  void _resetCharacter() {
    setState(() {
      _selectedHair = '01';
      _selectedFace = 'smile';
      _selectedClothes = '01'; // '01' (의상 없음)으로 리셋
      _selectedShoes = null;
      _selectedSkinColor = const Color(0xFFFFDAB9);
      _selectedHairColor = Colors.white;
      _selectedClothesColor = Colors.white;
      _selectedShoesColor = Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final categories = isEn ? _categoriesEn : _categoriesKo;
    final partsAsync = ref.watch(characterPartsProvider);

    // 초기 로딩 중일 때 로딩 화면 표시
    if (_isInitialLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
              Text('캐릭터 정보를 불러오는 중...', style: AppTextStyles.body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          partsAsync.when(
            data: (parts) => TextButton.icon(
              onPressed: () => _randomizeCharacter(parts),
              icon: const Icon(
                Icons.autorenew,
                size: 20,
                color: Colors.black87,
              ),
              label: Text(
                isEn ? 'Random' : '랜덤 꾸미기',
                style: AppTextStyles.subTitleM.copyWith(color: Colors.black87),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 캐릭터 영역 (SafeArea 밖에서 배경색이 상단까지 차도록 함)
          _buildCharacterSection(),
          // 카테고리 탭바 & 아이템 그리드
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  _buildCategoryTabBar(categories),
                  Expanded(child: _buildItemGrid(isEn, partsAsync)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(isEn),
    );
  }

  /// 상단 캐릭터 미리보기 영역
  Widget _buildCharacterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // RepaintBoundary로 감싸서 캡쳐 가능하게 함
          RepaintBoundary(
            key: _globalKey,
            child: CharacterPartsAvatar(
              baseImagePath: 'body_base.png',
              bodyShadowImagePath: 'body_shadow.png',
              baseColor: _selectedSkinColor,
              hairImagePath: 'hair_$_selectedHair.png',
              hairHighlightImagePath: 'hair_${_selectedHair}_highlight.png',
              hairShadowImagePath: 'hair_${_selectedHair}_shadow.png',
              hairSubShadowImagePath: 'hair_${_selectedHair}_sub_shadow.png',
              hairColor: _selectedHairColor,
              faceImagePath: 'face_$_selectedFace.png',
              clothesImagePath: 'clothes_$_selectedClothes.png',
              clothesColor: _selectedClothesColor,
              shoesImagePath: _selectedShoes != null
                  ? 'shoes_$_selectedShoes.png'
                  : null,
              shoesColor: _selectedShoesColor,
              size: 280,
            ),
          ),
        ],
      ),
    );
  }

  /// 색상 팔레트 영역
  Widget _buildColorPalette(int index) {
    if (index == 2) return const SizedBox.shrink(); // 의상/신발 탭은 색상 선택 안 함

    List<Color> currentPalette;
    Color selectedColor;
    Function(Color) onColorSelected;

    if (index == 0) {
      // 머리 탭
      selectedColor = _selectedHairColor;
      currentPalette = _palette; // 머리색은 일반 팔레트
      onColorSelected = (color) => _selectedHairColor = color;
    } else if (index == 1) {
      // 얼굴(피부) 탭
      selectedColor = _selectedSkinColor;
      currentPalette = _skinPalette; // 얼굴(피부)은 피부색 팔레트
      onColorSelected = (color) => _selectedSkinColor = color;
    } else if (index == 2) {
      // 옷 & 신발 탭
      selectedColor = _selectedClothesColor;
      currentPalette = _palette; // 옷 색상은 일반 팔레트
      onColorSelected = (color) => _selectedClothesColor = color;
    } else {
      // 해당 탭에 팔레트가 없는 경우
      return const SizedBox.shrink();
    }

    return Container(
      height: 70,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: currentPalette.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, idx) {
          final color = currentPalette[idx];
          final isSelected = color == selectedColor;
          return GestureDetector(
            onTap: () {
              setState(() {
                onColorSelected(color);
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 카테고리 탭바 (머리 / 표정 / 옷 / 신발)
  Widget _buildCategoryTabBar(List<String> categories) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent, // 기본 가로 실선 제거
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.green, // 녹색으로 변경
        indicatorWeight: 3, // 두께 증가
        indicatorSize: TabBarIndicatorSize.tab, // 탭 전체 너비로 확장
        labelStyle: AppTextStyles.subTitleM.copyWith(
          fontWeight: FontWeight.bold,
        ), // 글자 크기 및 굵기 강조
        unselectedLabelStyle: AppTextStyles.subTitleM,
        tabs: categories.asMap().entries.map((entry) {
          final svgIcons = [
            'assets/images/scissors.svg',
            'assets/images/smiley.svg',
            'assets/images/t-shirt.svg',
          ];
          return Tab(
            child: AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, child) {
                double offset = (_tabController.animation!.value - entry.key)
                    .abs();
                double t = (1.0 - offset).clamp(0.0, 1.0);
                final color = Color.lerp(Colors.grey, Colors.black, t)!;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      svgIcons[entry.key],
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.value,
                      style: TextStyle(
                        color: color,
                        fontWeight: t > 0.5 ? FontWeight.bold : FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 아이템 선택 그리드 (각 탭별로 팔레트와 그리드를 포함)
  Widget _buildItemGrid(
    bool isEn,
    AsyncValue<Map<String, List<String>>> partsAsync,
  ) {
    return partsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (parts) {
        final hairs = parts['hairs'] ?? [];
        final faces = parts['faces'] ?? [];
        final clothes = (parts['clothes'] ?? [])
            .where((id) => id != '01')
            .toList();
        final shoes = parts['shoes'] ?? [];

        return Container(
          color: Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: [
              // 0. 머리 탭
              Column(
                children: [
                  _buildColorPalette(0),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _buildGridForCategory(
                      'hair',
                      hairs,
                      _selectedHair,
                      (id) => setState(() => _selectedHair = id),
                    ),
                  ),
                ],
              ),
              // 1. 얼굴 탭
              Column(
                children: [
                  _buildColorPalette(1),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _buildGridForCategory(
                      'face',
                      faces,
                      _selectedFace,
                      (id) => setState(() => _selectedFace = id),
                      deselectId: 'smile', // 얼굴은 중복 선택 시 smile로 고정
                    ),
                  ),
                ],
              ),
              // 2. 옷 & 신발 탭
              Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        children: [
                          _buildSectionTitle(isEn ? 'Clothes' : '의상'),
                          _buildCompactGrid(
                            'clothes',
                            clothes,
                            _selectedClothes,
                            (id) {
                              if (id != null) {
                                setState(() => _selectedClothes = id);
                              }
                            },
                            allowDeselect: true,
                            deselectId: '01',
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle(isEn ? 'Shoes' : '신발'),
                          _buildCompactGrid(
                            'shoes',
                            shoes,
                            _selectedShoes,
                            (id) => setState(() => _selectedShoes = id),
                            allowDeselect: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 옷과 신발을 함께 보여주는 탭 빌더 (이제 사용되지 않음)
  // Widget _buildClothesAndShoesTab(bool isEn) {
  //   return Container(
  //     color: Colors.white,
  //     child: ListView(
  //       padding: const EdgeInsets.all(20),
  //       children: [
  //         _buildSectionTitle(isEn ? 'Clothes' : '의상'),
  //         _buildCompactGrid(
  //           'clothes',
  //           _clothes,
  //           _selectedClothes,
  //           (id) {
  //             if (id != null) setState(() => _selectedClothes = id);
  //           },
  //           allowDeselect: true,
  //           deselectId: '01',
  //         ),
  //         const SizedBox(height: 32),
  //         _buildSectionTitle(isEn ? 'Shoes' : '신발'),
  //         _buildCompactGrid(
  //           'shoes',
  //           _shoes,
  //           _selectedShoes,
  //           (id) => setState(() => _selectedShoes = id),
  //           allowDeselect: true,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.subTitleL),
    );
  }

  Widget _buildCompactGrid(
    String type,
    List<String> items,
    String? selectedId,
    Function(String?) onSelect, {
    bool allowDeselect = false,
    String? deselectId,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final itemId = items[index];
        final isSelected = itemId == selectedId;
        return GestureDetector(
          onTap: () {
            if (isSelected && allowDeselect) {
              onSelect(deselectId);
            } else {
              onSelect(itemId);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildNetworkImage(
                  _getPartUrl(type, itemId, isThumbnail: true),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridForCategory(
    String type,
    List<String> items,
    String selectedId,
    Function(String) onSelect, {
    String deselectId = '01',
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // 상단 패딩 20에서 10으로 축소
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final itemId = items[index];
          final isSelected = itemId == selectedId;

          return GestureDetector(
            onTap: () {
              // 이미 선택된 아이템을 다시 터치하면 deselectId(기본값)로 원복
              if (isSelected) {
                onSelect(deselectId);
              } else {
                onSelect(itemId);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildNetworkImage(
                    _getPartUrl(type, itemId, isThumbnail: true),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 캐릭터 저장 로직
  Future<void> _saveCharacter() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(userProvider).value;
      final isEn = ref.read(localeProvider) == AppLocale.en;

      if (user == null) {
        throw Exception(
          isEn
              ? 'User info not found. Please log in again.'
              : '사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.',
        );
      }

      // UI 스레드가 로딩 상태를 그릴 시간을 줌
      await Future.delayed(const Duration(milliseconds: 100));

      // 1. 이미지 캡쳐
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) throw Exception('아바타 이미지를 캡쳐할 수 없습니다.');

      ui.Image image = await boundary.toImage(
        pixelRatio: 2.0,
      ); // 3.0은 너무 무거울 수 있어 2.0으로 하향
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) throw Exception('이미지 변환에 실패했습니다.');

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. 얼굴 영역 크롭 (image 패키지 사용)
      final decodedImage = await Future(() => img.decodeImage(pngBytes));
      if (decodedImage == null) throw Exception('이미지 파일을 해석할 수 없습니다.');

      // 얼굴 부위 추출 (캐릭터의 55% 영역으로 설정 - 확대감과 여백의 균형)
      final int cropSize = (decodedImage.width * 0.6).toInt();
      final int cropX = (decodedImage.width - cropSize) ~/ 2;
      final int cropY = (decodedImage.height * 0.00)
          .toInt(); // 상단 정수리 부분이 잘리지 않도록 오프셋 축소

      final croppedImage = img.copyCrop(
        decodedImage,
        x: cropX,
        y: cropY,
        width: cropSize,
        height: cropSize,
      );

      final croppedBytes = Uint8List.fromList(img.encodePng(croppedImage));
      if (croppedBytes.isEmpty) throw Exception('이미지 압축에 실패했습니다.');

      // 3. Storage 및 Firestore 업데이트 (Repository 패턴 적용)
      final characterSettings = {
        'hair': _selectedHair,
        'face': _selectedFace,
        'clothes': _selectedClothes,
        'shoes': _selectedShoes,
        'skinColor': _selectedSkinColor.toARGB32(),
        'hairColor': _selectedHairColor.toARGB32(),
        'clothesColor': _selectedClothesColor.toARGB32(),
        'shoesColor': _selectedShoesColor.toARGB32(),
      };

      final characterRepo = ref.read(characterRepositoryProvider);
      await characterRepo.saveCharacterSettings(
        user,
        characterSettings,
        croppedBytes,
      );

      if (mounted) {
        // 성공 시 홈으로 이동 (라우터의 리다이렉트 로직에 의해 이름이 없으면 이름 설정으로 이동함)
        context.goNamed(AppRoute.home.name);
      }
    } catch (e) {
      if (mounted) {
        final isEn = ref.read(localeProvider) == AppLocale.en;
        AppToast.show(context, isEn ? 'Save failed: $e' : '저장 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// 하단 뒤로가기 + 다음 버튼
  Widget _buildBottomButtons(bool isEn) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // 초기화 버튼 (Undo 아이콘)
              GestureDetector(
                onTap: _isSaving ? null : _resetCharacter,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 완료 버튼
              Expanded(
                child: GestureDetector(
                  onTap: _isSaving ? null : _saveCharacter,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isSaving ? Colors.grey : AppColors.primary700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEn ? 'Save' : '저장하기',
                            style: AppTextStyles.subTitleL.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Firebase Storage 다운로드 URL 조성을 위한 기본 URL
  static const _storageBaseUrl =
      'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/';

  /// 에셋 경로를 Firebase Storage URL로 변환
  String _getPartUrl(String type, String itemId, {bool isThumbnail = false}) {
    if (isThumbnail) {
      return '${_storageBaseUrl}parts%2Fthumbnails%2F${type}_$itemId.png?alt=media';
    }
    return '${_storageBaseUrl}parts%2F${type}_$itemId.png?alt=media';
  }

  Widget _buildNetworkImage(String url, {double? width, double? height}) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.error_outline, size: 20),
    );
  }
}
