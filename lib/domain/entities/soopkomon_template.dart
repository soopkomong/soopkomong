import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/domain/entities/soopkomon_enums.dart';

/// 모든 숲코몽 종류의 원본 데이터를 담는 템플릿 엔티티
class SoopkomonTemplate {
  final String templateId; // 도감 번호 (예: '001')
  final String grade; // 캐릭터 등급 (예: 'A', 'S')
  final String name; // 캐릭터 이름
  final String description; // 캐릭터 설명 (도감용)
  final SoopkomonEggType eggType; // 해당 캐릭터가 나오는 알의 타입
  final Region region; // 해당 캐릭터가 발견되는 주 지역

  SoopkomonTemplate({
    required this.templateId,
    required this.grade,
    required this.name,
    required this.description,
    required this.eggType,
    required this.region,
  });

  /// 🔹 규칙에 따른 이미지 경로 자동 생성 (로컬/원격 겸용)
  String get actualImagePath {
    // templateId가 비어있지 않은 경우 Firebase Storage 경로를 시도할 수 있음
    // 기본적으로는 로컬 에셋 경로를 반환하지만,
    // 나중에 Firestore 데이터에 따라 URL을 직접 가질 수도 있습니다.
    return 'assets/images/characters/${templateId}_big.png';
  }

  /// 🔹 Firebase Storage용 URL 생성 (템플릿 ID 기반)
  String get remoteImagePath =>
      'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/characters%2F${templateId}_big.png?alt=media';

  /// 알 이미지 경로는 타입을 통해 결정됨
  String get eggImagePath => eggType.imagePath;

  /// 🔹 등급별 부화에 필요한 걸음수
  int get requiredSteps {
    switch (grade.toUpperCase()) {
      case 'S':
        return 10000;
      case 'A':
        return 5000;
      case 'B':
        return 3000;
      case 'C':
        return 1000;
      default:
        return 1000;
    }
  }
}
