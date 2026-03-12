import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/domain/entities/soopkomon_enums.dart';

/// 모든 숲코몽 종류의 원본 데이터를 담는 템플릿 엔티티
class SoopkomonTemplate {
  final String templateId; // 도감 번호 (예: '001')
  final String name; // 캐릭터 이름
  final String description; // 캐릭터 설명 (도감용)
  final SoopkomonEggType eggType; // 해당 캐릭터가 나오는 알의 타입
  final Region region; // 해당 캐릭터가 발견되는 주 지역

  SoopkomonTemplate({
    required this.templateId,
    required this.name,
    required this.description,
    required this.eggType,
    required this.region,
  });

  /// 🔹 규칙에 따른 이미지 경로 자동 생성
  String get actualImagePath =>
      'assets/images/characters/${templateId}_big.png';

  /// 알 이미지 경로는 타입을 통해 결정됨
  String get eggImagePath => eggType.imagePath;
}
