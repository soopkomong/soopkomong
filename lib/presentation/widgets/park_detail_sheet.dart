import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/expandable_text.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';

class ParkDetailSheet extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String information;
  final String tel;
  final bool isVisited;

  const ParkDetailSheet({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.information,
    required this.tel,
    required this.isVisited,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.4, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              const SizedBox(height: 12),

              /// 🔹 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 상단 이미지
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        imageUrl.isNotEmpty
                            ? imageUrl
                            : 'https://picsum.photos/800/600',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    /// 이미지 수
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '1/1',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    /// 이미지 인디케이터
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 공원 이름
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 공원 소개 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  leading: const Icon(Icons.description_outlined),
                  title: '공원 소개',
                  child: ExpandableText(
                    text:
                        '[제목] $name\n'
                        '[주소] $address\n'
                        '[개요] $description\n\n'
                        '${tel.isNotEmpty ? '* 문의 : $tel \n\n' : ''}'
                        '$information',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 얻을 수 있는 캐릭터 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  leading: Image.asset(
                    'assets/images/character_silhouette.png',
                    width: 24,
                  ),
                  title: '얻을 수 있는 캐릭터',
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDEDED),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/character_silhouette.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 위치 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 4,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔹 이미지
                      Container(
                        width: double.infinity,
                        height: 199.33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(
                              imageUrl.isNotEmpty
                                  ? imageUrl
                                  : "https://picsum.photos/800/600",
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      // 🔹 텍스트 영역
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(
                                  color: Color(0xFF191919),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
