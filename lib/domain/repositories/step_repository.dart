abstract class StepRepository {
  /// 현재까지의 총 누적 걸음수를 가져옵니다. (재부팅 내성 있음)
  Future<int> getTotalSteps();

  /// 새로운 센서 데이터(Pedometer)를 기반으로 누적 걸음수를 업데이트합니다.
  Future<int> updateFromPedometer(int pedometerValue);

  /// 건강 앱(HealthKit/Google Fit)으로부터 걸음수를 동기화합니다.
  Future<int> syncWithHealthApp();

  /// 마지막으로 저장된 누적 걸음수를 초기화합니다. (테스트용)
  Future<void> clearSteps();
}
