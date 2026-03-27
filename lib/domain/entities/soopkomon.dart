/// 유저가 획득한 숲코몽의 인스턴스 정보를 담는 엔티티
class Soopkomon {
  final String instanceId; // 개별 캐릭터의 고유 식별값 (UUID 등)
  final String templateId; // 캐릭터 종류 번호 (예: 001, 002)
  final String name; // 캐릭터에게 붙여준 이름 (기본값은 템플릿 이름)

  // 0. 이미지 경로 (템플릿 ID 기반 자동 완성)
  // 0. 이미지 경로
  String get imagePath {
    if (!isHatched) {
      if (templateId == '000') {
        return 'assets/images/egg/egg_tuto.png';
      }
      return 'assets/images/egg/egg_mystery.png';
    }
    return 'assets/images/characters/${templateId}_big.png';
  }

  // 1. 발견 정보
  final String discoveredSpotId; // 발견된 장소의 고유 ID (contentId)
  final String discoveredSpotName; // 발견된 장소의 이름 (title)
  final String discoveredAddr; // 발견된 장소의 주소
  final DateTime discoveredAt; // 발견 시각

  // 2. 걸음수 기록 (성장 추적용)
  final int stepsAtDiscovery; // 발견 당시 유저의 누적 걸음수
  int currentTotalSteps; // 유저의 현재 최신 누적 걸음수 (업데이트용)
  final bool isHatched; // 부화 여부
  final String grade; // 캐릭터 등급 (S, A, B, C)

  Soopkomon({
    required this.instanceId,
    required this.templateId,
    required this.name,
    required this.discoveredSpotId,
    required this.discoveredSpotName,
    required this.discoveredAddr,
    required this.discoveredAt,
    required this.stepsAtDiscovery,
    this.currentTotalSteps = 0,
    this.isHatched = false,
    this.grade = 'C',
  });

  // 3. 실시간 계산 필드 (Getter)
  int get traveledSteps => currentTotalSteps - stepsAtDiscovery;

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
      case 'T': // 튜토리얼용 특별 등급
        return 500;
      default:
        return 1000;
    }
  }

  /// 신규 유저를 위한 초기 '알' 객체 생성 (튜토리얼용 000번)
  factory Soopkomon.tutorialEgg() {
    return Soopkomon(
      instanceId: 'tutorial_egg_000',
      templateId: '000',
      name: '신비한 알',
      discoveredSpotId: 'tutorial_start',
      discoveredSpotName: '숲코몽 세계의 입구',
      discoveredAddr: '미지의 숲',
      discoveredAt: DateTime.now(),
      stepsAtDiscovery: 0,
      currentTotalSteps: 0,
      grade: 'T',
    );
  }



  /// 상태 업데이트를 위한 copyWith
  Soopkomon copyWith({
    String? name,
    int? currentTotalSteps,
    bool? isHatched,
    String? grade,
  }) {
    return Soopkomon(
      instanceId: instanceId,
      templateId: templateId,
      name: name ?? this.name,
      discoveredSpotId: discoveredSpotId,
      discoveredSpotName: discoveredSpotName,
      discoveredAddr: discoveredAddr,
      discoveredAt: discoveredAt,
      stepsAtDiscovery: stepsAtDiscovery,
      currentTotalSteps: currentTotalSteps ?? this.currentTotalSteps,
      isHatched: isHatched ?? this.isHatched,
      grade: grade ?? this.grade,
    );
  }
}
