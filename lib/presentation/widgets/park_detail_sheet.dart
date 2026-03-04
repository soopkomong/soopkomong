import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/expandable_text.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';

class ParkDetailSheet extends StatelessWidget {
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
                        'https://picsum.photos/800/600?random=$index',
                        fit: BoxFit.cover,
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
                          '1/3',
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
                        children: List.generate(
                          3,
                          (dotIndex) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotIndex == 0
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
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
                  child: const ExpandableText(
                    text:
                        '[제목] 제천솔방죽 생태공원\n'
                        '[주소] 충청북도 제천시 청전동 240-1 일원\n'
                        '[개요] 2005년 11월부터 2006년 11월까지 1년간 청전제천 21 실천협의회 연구분과위원회에서 연구, 조사를 위탁하고 모니터링하여 사업비 14억 6천7백만 원 을 들여 시내권 내에 조성한 생태공원이다. 솔방죽의 저수 유입은 비룡담(제2 의림지)으로부터 농업용수를 사용 후 잠시 이곳에 저장된다. 원래의 연못은 1872년에 제작된 군, 현 지도에 ‘유등지’로 표기되었으나 ‘작은 연못’으로 불렸는데 청정제천 21 실천협의회에서 공원화 조성에 따라 ‘솔방죽’으로 이름을 붙였으며 제천시에서 처음으로 생태공원이라는 이름을 붙여 조성한 곳이다. 생태공원의 규모는 연면적 28,096㎡ 로 동서 220m, 남북 80~100m의 크기 저수지에 3개의 지역으로 나누어 조성되었다.\n\n'
                        '* 문의 : 043-641-6731~3 \n'
                        '* 휴무일 : 연중무휴 \n\n'
                        '◎이용안내\n'
                        '- 이용요금 : 무료\n'
                        '- 화장실 : 있음(남녀구분) \n'
                        '- 장애인 편의시설 : 장애인화장실 있음(남녀공용) \n'
                        '- 주차시설 : 불가능',
                    style: TextStyle(fontSize: 13, height: 1.5),
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
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://picsum.photos/seed/1/358/199",
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
                            Icon(Icons.location_on_outlined),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                '충청북도 제천시 청전동 240-1 일원',
                                style: TextStyle(
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
