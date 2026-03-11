/// 유저가 획득한 숲코몽의 인스턴스 정보를 담는 엔티티
class Soopkomon {
  final String instanceId;         // 개별 캐릭터의 고유 식별값 (UUID 등)
  final String templateId;         // 캐릭터 종류 번호 (예: 001, 002)
  final String name;               // 캐릭터에게 붙여준 이름 (기본값은 템플릿 이름)
  
  // 0. 이미지 경로 (템플릿 ID 기반 자동 완성)
  String get imagePath => 'assets/images/characters/${templateId}_big.png';

  // 1. 발견 정보
  final String discoveredSpotId;   // 발견된 장소의 고유 ID (contentId)
  final String discoveredSpotName; // 발견된 장소의 이름 (title)
  final String discoveredAddr;     // 발견된 장소의 주소
  final DateTime discoveredAt;     // 발견 시각

  // 2. 걸음수 기록 (성장 추적용)
  final int stepsAtDiscovery;      // 발견 당시 유저의 누적 걸음수
  int currentTotalSteps;           // 유저의 현재 최신 누적 걸음수 (업데이트용)

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
  });

  // 3. 실시간 계산 필드 (Getter)
  // 발견 이후 함께한 걸음수 = (현재 총 걸음수 - 발견 당시 걸음수)
  int get traveledSteps => currentTotalSteps - stepsAtDiscovery;

  /// 상태 업데이트를 위한 copyWith
  Soopkomon copyWith({
    String? name,
    int? currentTotalSteps,
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
    );
  }
}
