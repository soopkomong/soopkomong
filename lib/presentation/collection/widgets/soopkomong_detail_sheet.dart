import 'package:flutter/material.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_egg_detail_view.dart';
import 'package:soopkomong/presentation/collection/widgets/soopkomong_hatched_detail_view.dart';

class SoopkomongDetailSheet extends StatelessWidget {
  final SoopkomonTemplate template;
  final Soopkomon? soopkomon;
  final bool isRegionVisited;
  final int currentSteps;

  const SoopkomongDetailSheet({
    super.key,
    required this.template,
    this.soopkomon,
    this.isRegionVisited = false,
    this.currentSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 실제 부화 여부 (Firestore 데이터 기준)
    final bool finalIsDiscovered = soopkomon?.isHatched ?? false;
    // 획득은 했으나 아직 부화하지 않은 상태 (알 상태)
    final bool hasEgg = soopkomon != null && !finalIsDiscovered;

    return DraggableScrollableSheet(
      initialChildSize: hasEgg ? 0.6 : 0.8, // 알 상태일 때 높이 축소
      minChildSize: 0.4,
      maxChildSize: hasEgg ? 0.7 : 0.9,
      expand: false,
      snap: true,
      snapSizes: hasEgg ? const [0.4, 0.65] : const [0.4, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // 상단 핸들
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    if (hasEgg)
                      SoopkomongEggDetailView(
                        template: template,
                        soopkomon: soopkomon,
                      )
                    else
                      SoopkomongHatchedDetailView(
                        template: template,
                        soopkomon: soopkomon,
                        isDiscovered: finalIsDiscovered,
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
