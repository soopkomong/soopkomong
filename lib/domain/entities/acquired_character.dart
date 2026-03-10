/// 유저가 획득한 캐릭터의 정보를 담는 클래스
class AcquiredCharacter {
  final int locationId; // 발견된 장소 ID
  final String name; // 캐릭터 이름
  final DateTime discoveredAt; // 발견 시각
  final int stepsAtDiscovery; // 발견 당시 유저의 누적 걸음수
  final int currentTotalSteps; // 유저의 현재 최신 누적 걸음수 (업데이트 필요)

  AcquiredCharacter({
    required this.locationId,
    required this.name,
    required this.discoveredAt,
    required this.stepsAtDiscovery,
    required this.currentTotalSteps,
  });

  /// 발견 이후 함께한 걸음수 실시간 계산 필드
  int get traveledSteps => currentTotalSteps - stepsAtDiscovery;

  /// 현재 걸음수를 업데이트한 새로운 객체를 반환합니다.
  AcquiredCharacter copyWith({int? currentTotalSteps}) {
    return AcquiredCharacter(
      locationId: locationId,
      name: name,
      discoveredAt: discoveredAt,
      stepsAtDiscovery: stepsAtDiscovery,
      currentTotalSteps: currentTotalSteps ?? this.currentTotalSteps,
    );
  }
}
