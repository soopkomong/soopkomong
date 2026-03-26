class StepData {
  final int todaySteps;
  final int totalSteps;

  StepData({required this.todaySteps, required this.totalSteps});
}

abstract class StepRepository {
  /// 오늘 하루의 총 걸음수를 가져옵니다. (자정 리셋)
  Future<int> getTodaySteps();

  /// 현재까지의 총 누적 걸음수를 가져옵니다. (재부팅 내성 있음, 부화 로직용)
  Future<int> getTotalSteps();

  /// 새로운 센서 데이터(Pedometer)를 기반으로 걸음수를 업데이트합니다.
  Future<StepData> updateFromPedometer(int pedometerValue);

  /// 건강 앱(HealthKit/Google Fit)으로부터 걸음수를 동기화합니다.
  Future<StepData> syncWithHealthApp();

  /// 마지막으로 저장된 누적 걸음수를 초기화합니다. (테스트용)
  Future<void> clearSteps();
}
