import 'package:flutter/material.dart';

class ParkDetailSheet extends StatefulWidget {
  final String id;
  final String name;
  final int index;
  final bool isVisited;

  const ParkDetailSheet({
    super.key,
    required this.id,
    required this.name,
    required this.index,
    required this.isVisited,
  });

  @override
  State<ParkDetailSheet> createState() => _ParkDetailSheetState();
}

class _ParkDetailSheetState extends State<ParkDetailSheet> {
  final PageController _imagePageController = PageController();
  int _currentImagePage = 0;
  bool _isExpanded = false;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      snapSizes: const [0.5, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // 상단 핸들과 닫기 버튼 (고정 영역)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 스크롤 가능한 컨텐츠 영역
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  children: [
                    // 이미지 슬라이더 영역
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: PageView.builder(
                              controller: _imagePageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImagePage = index;
                                });
                              },
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  'https://picsum.photos/800/600?random=${widget.index + index}',
                                  fit: BoxFit.cover,
                                  color: widget.isVisited ? null : Colors.grey,
                                  colorBlendMode: widget.isVisited
                                      ? null
                                      : BlendMode.saturation,
                                );
                              },
                            ),
                          ),
                        ),
                        // 페이지 표시 (1/3)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentImagePage + 1}/3',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 점 인디케이터
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImagePage == index
                                ? Colors.grey[600]
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 공원 이름
                    Center(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 공원 설명 섹션
                    const Text(
                      '공원 설명',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lorem ipsum dolor sit amet consectetur. Elit ornare rhoncus morbi quis egestas sed leo. Congue amet semper nec tempus ac sagittis posuere urna libero. Aliquam lectus neque massa urna.',
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 더보기 버튼
                    Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4AC6D7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isExpanded ? '접기' : '+더보기',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 얻을 수 있는 캐릭터 섹션
                    const Text(
                      '얻을 수 있는 캐릭터',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8DCCB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/character_silhouette.png',
                                width: 60,
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 지도 영역 (이미지 프레임)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://picsum.photos/600/400?random=map',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            // 지도 위 핀 아이콘 중앙 배치
                            const Center(
                              child: Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                            // 하단 카카오/네이버 로고 느낌의 텍스트
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Text(
                                'kakao',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 주소 정보
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '충청북도 제천시 청전동 240-1 일원',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
