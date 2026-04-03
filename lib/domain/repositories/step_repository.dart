class StepData {
  final int todaySteps;
  final int totalSteps;
  final int delta; // 이번 업데이트에서 증가한 걸음수

  StepData({
    required this.todaySteps,
    required this.totalSteps,
    required this.delta,
  });
}

abstract class StepRepository {
  /// 오늘 하루의 총 걸음수를 가져옵니다. (자정 리셋)
  Future<int> getTodaySteps();

  /// 현재까지의 총 누적 걸음수를 가져옵니다. (재부팅 내성 있음, 부화 로직용)
  Future<int> getTotalSteps();

  /// 오늘 하루의 걸음수를 강제로 설정합니다. (테스트용)
  Future<void> setTodaySteps(int steps);

  /// 앱 재설치 등 초기화 상황에서 Firestore의 누적 걸음수로 덮어씌웁니다.
  Future<void> setTotalSteps(int steps);

  /// 새로운 센서 데이터(Pedometer)를 기반으로 걸음수를 업데이트합니다.
  Future<StepData> updateFromPedometer(int pedometerValue);

  /// 가입 완료 시점 등 특정 시점을 0보 기준점으로 초기화합니다.
  Future<void> initializeBaseline(int currentSensorValue);

  /// 마지막으로 저장된 누적 걸음수를 초기화합니다. (테스트용)
  Future<void> clearSteps();
}
