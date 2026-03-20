import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/mypage/character_page/widgets/character_create_popup.dart';
import 'package:soopkomong/presentation/widgets/character_avatar.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_router.dart';

import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const _categoriesKo = ['머리', '얼굴', '옷'];
  static const _categoriesEn = ['Hair', 'Face', 'Clothes'];

  // 선택된 파츠 상태
  String _selectedHair = '01';
  String _selectedFace = 'smile';
  String _selectedClothes = '01';
  // 신발은 탭에서는 빠졌지만 아바타에 넘겨야 하므로 기본값 유지
  String? _selectedShoes; // 기본적으로 신발 안 신음 (null)

  // 선택된 색상 상태 (선택된 카테고리에 따라 적용됨)
  Color _selectedSkinColor = const Color(0xFFFFDAB9); // 기본 피부색 (Light Peach)
  Color _selectedHairColor = Colors.white;
  Color _selectedClothesColor = Colors.white;
  Color _selectedShoesColor = Colors.white;

  // 더미 데이터 (실제 데이터에 맞게 확장 가능)
  final List<String> _hairs = ['01', '02', '03'];
  final List<String> _faces = ['smile'];
  final List<String> _clothes = ['02']; // '01'은 기본 옷이므로 선택지에서 제외
  final List<String> _shoes = ['01']; // 신발 아이템 리 목록

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
    final categories = ref.read(localeProvider) == AppLocale.en ? _categoriesEn : _categoriesKo;
    _tabController = TabController(length: categories.length, vsync: this);

    // 1. 기존 캐릭터 데이터 로드
    final user = ref.read(userProvider).value;
    if (user != null && user.characterSettings != null) {
      final settings = user.characterSettings!;
      _selectedHair = settings['hair'] ?? '01';
      _selectedFace = settings['face'] ?? 'smile';
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
  }

  void _randomizeCharacter() {
    setState(() {
      _selectedHair = (_hairs.toList()..shuffle()).first;
      _selectedClothes = (_clothes.toList()..shuffle()).first;
      _selectedShoes = (_shoes.toList()..shuffle()).first; // 신발도 랜덤 포함
      _selectedHairColor = (_palette.toList()..shuffle()).first;
      _selectedClothesColor = (_palette.toList()..shuffle()).first;
      _selectedSkinColor =
          (_skinPalette.toList()..shuffle()).first; // 피부색도 취향껏 랜덤
    });
  }

  void _resetCharacter() {
    setState(() {
      _selectedHair = '01';
      _selectedFace = 'smile';
      _selectedClothes = '01';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _randomizeCharacter,
            icon: const Icon(Icons.autorenew, size: 20, color: Colors.black87),
            label: Text(
              isEn ? 'Random' : '랜덤 꾸미기',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 캐릭터 영역
            _buildCharacterSection(),
            // 카테고리 탭바
            _buildCategoryTabBar(categories),
            // 현재 선택된 탭의 색상 팔레트
            _buildColorPalette(),
            // 아이템 그리드
            Expanded(child: _buildItemGrid(isEn)),
            // 하단 버튼
            _buildBottomButtons(isEn),
          ],
        ),
      ),
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
            child: CharacterAvatar(
              baseImagePath: 'assets/images/parts/body_base.png',
              bodyShadowImagePath: 'assets/images/parts/body_shadow.png',
              baseColor: _selectedSkinColor,
              hairImagePath: 'assets/images/parts/hair_$_selectedHair.png',
              hairHighlightImagePath:
                  'assets/images/parts/hair_${_selectedHair}_highlight.png',
              hairShadowImagePath:
                  'assets/images/parts/hair_${_selectedHair}_shadow.png',
              hairSubShadowImagePath:
                  'assets/images/parts/hair_${_selectedHair}_sub_shadow.png',
              hairColor: _selectedHairColor,
              faceImagePath: 'assets/images/parts/face_$_selectedFace.png',
              clothesImagePath:
                  'assets/images/parts/clothes_$_selectedClothes.png',
              clothesColor: _selectedClothesColor,
              shoesImagePath: _selectedShoes != null
                  ? 'assets/images/parts/shoes_$_selectedShoes.png'
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
  Widget _buildColorPalette() {
    Color selectedColor;
    List<Color> currentPalette;

    if (_tabController.index == 0) {
      selectedColor = _selectedHairColor;
      currentPalette = _palette; // 머리색은 일반 팔레트
    } else if (_tabController.index == 1) {
      selectedColor = _selectedSkinColor;
      currentPalette = _skinPalette; // 얼굴(피부)은 피부색 팔레트
    } else {
      // 옷/신발 탭일 때는 팔레트를 보여주지 않음
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: currentPalette.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = currentPalette[index];
          final isSelected = color == selectedColor;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (_tabController.index == 0) {
                  _selectedHairColor = color;
                } else if (_tabController.index == 1) {
                  _selectedSkinColor = color;
                } else if (_tabController.index == 2) {
                  _selectedClothesColor = color;
                }
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
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: categories.asMap().entries.map((entry) {
          final icons = [Icons.content_cut, Icons.face, Icons.checkroom];
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icons[entry.key], size: 14),
                const SizedBox(width: 4),
                Text(entry.value),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 아이템 선택 그리드
  Widget _buildItemGrid(bool isEn) {
    return TabBarView(
      controller: _tabController,
      children: [
        // 0. 머리 탭
        _buildGridForCategory(
          'hair',
          _hairs,
          _selectedHair,
          (id) => setState(() => _selectedHair = id),
        ),
        // 1. 얼굴 탭 (표정 선택 + 피부색상 상단표시)
        _buildGridForCategory(
          'face',
          _faces,
          _selectedFace,
          (id) => setState(() => _selectedFace = id),
        ),
        // 2. 옷 & 신발 탭
        _buildClothesAndShoesTab(isEn),
      ],
    );
  }

  /// 옷과 신발을 함께 보여주는 탭 빌더
  Widget _buildClothesAndShoesTab(bool isEn) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(isEn ? 'Clothes' : '의상'),
          _buildCompactGrid(
            'clothes',
            _clothes,
            _selectedClothes,
            (id) {
              if (id != null) setState(() => _selectedClothes = id);
            },
            allowDeselect: true,
            deselectId: '01',
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(isEn ? 'Shoes' : '신발'),
          _buildCompactGrid(
            'shoes',
            _shoes,
            _selectedShoes,
            (id) => setState(() => _selectedShoes = id),
            allowDeselect: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
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
        String imagePath = 'assets/images/parts/${type}_$itemId.png';

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
              child: Image.asset(imagePath, fit: BoxFit.contain),
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
    Function(String) onSelect,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
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

          // 미리보기 이미지 경로 (썸네일용)
          String imagePath = 'assets/images/parts/${type}_$itemId.png';

          return GestureDetector(
            onTap: () {
              // 옷 탭에서 이미 입고 있는 옷을 다시 터치하면 기본 옷(01)으로 원복
              if (isSelected && type == 'clothes') {
                onSelect('01');
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
                child: Image.asset(imagePath, fit: BoxFit.contain),
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
        throw Exception(isEn ? 'User info not found. Please log in again.' : '사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
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

      // 3. Firebase Storage 관리
      final storage = FirebaseStorage.instance;

      // 기존 이미지 삭제 시도 (Firebase Storage 이미지인 경우에만)
      if (user.photoUrl != null &&
          user.photoUrl!.contains('firebasestorage.googleapis.com')) {
        try {
          await storage.refFromURL(user.photoUrl!).delete();
        } catch (e) {
          debugPrint('기존 이미지 삭제 실패(무시가능): $e');
        }
      }

      // 새 이미지 업로드
      final fileName =
          'profiles/${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final uploadTask = await storage.ref(fileName).putData(croppedBytes);
      final photoUrl = await uploadTask.ref.getDownloadURL();

      // 4. Firestore 업데이트
      final characterSettings = {
        'hair': _selectedHair,
        'face': _selectedFace,
        'clothes': _selectedClothes,
        'shoes': _selectedShoes,
        'hairColor': _selectedHairColor.toARGB32(),
        'skinColor': _selectedSkinColor.toARGB32(),
        'clothesColor': _selectedClothesColor.toARGB32(),
        'shoesColor': _selectedShoesColor.toARGB32(),
      };

      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'has_character': true,
        'photoUrl': photoUrl,
        'character_settings': characterSettings,
      }, SetOptions(merge: true));

      if (mounted) {
        // 성공 시 페이지 이동 (라우터 리프레시 유도)
        context.goNamed(AppRoute.home.name);
      }
    } catch (e) {
      if (mounted) {
        final isEn = ref.read(localeProvider) == AppLocale.en;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEn ? 'Save failed: $e' : '저장 실패: $e')),
        );
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: Colors.white,
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
              child: const Icon(Icons.refresh, color: Colors.white, size: 24),
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
                  color: _isSaving ? Colors.grey : Colors.black87,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
