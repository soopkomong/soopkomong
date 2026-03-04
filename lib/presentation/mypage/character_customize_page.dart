import 'package:flutter/material.dart';

class CharacterCustomizePage extends StatefulWidget {
  const CharacterCustomizePage({super.key});

  @override
  State<CharacterCustomizePage> createState() => _CharacterCustomizePageState();
}

class _CharacterCustomizePageState extends State<CharacterCustomizePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _categories = ['머리', '얼굴', '색상'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '캐릭터 꾸미기',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 캐릭터 영역
            _buildCharacterSection(),
            // 카테고리 탭바
            _buildCategoryTabBar(),
            // 아이템 그리드
            Expanded(child: _buildItemGrid()),
            // 하단 버튼
            _buildBottomButtons(),
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
          // 랜덤 꾸미기 버튼
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  // TODO: 랜덤 꾸미기 로직
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.autorenew, size: 16, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      '랜덤 꾸미기',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 캐릭터 이미지
          Image.asset(
            'assets/images/my.png',
            height: 200,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  /// 카테고리 탭바 (머리 / 얼굴 / 색상)
  Widget _buildCategoryTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: _categories.asMap().entries.map((entry) {
          final icons = [Icons.content_cut, Icons.face, Icons.palette];
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

  /// 아이템 선택 그리드 (카테고리별 16개)
  Widget _buildItemGrid() {
    return TabBarView(
      controller: _tabController,
      children: _categories.map((category) {
        return _buildGridForCategory(category);
      }).toList(),
    );
  }

  Widget _buildGridForCategory(String category) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: 16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // TODO: 아이템 선택 로직
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 하단 뒤로가기 + 다음 버튼
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: const Color(0xFFF5F5F5),
      child: Row(
        children: [
          // 뒤로가기 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.undo,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 다음 버튼
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: 다음 단계 로직
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '다음',
                  style: TextStyle(
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
