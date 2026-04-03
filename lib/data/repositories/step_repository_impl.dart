import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/domain/repositories/step_repository.dart';
import 'package:flutter/foundation.dart';

class StepRepositoryImpl implements StepRepository {
  static const String _keyTotalSteps = 'total_accumulated_steps';
  static const String _keyTodaySteps = 'today_steps';
  static const String _keyLastUpdateDate = 'last_step_update_date';
  static const String _keyBaselinePedometer = 'baseline_pedometer_value'; // 자정 시점 Pedometer 원시값
  static const String _keyLastPedometer = 'last_known_pedometer_value'; // 재부팅/감소 감지용 이전 원시값

  final SharedPreferences _prefs;

  StepRepositoryImpl(this._prefs);

  @override
  Future<int> getTotalSteps() async {
    return _prefs.getInt(_keyTotalSteps) ?? 0;
  }

  @override
  Future<void> setTotalSteps(int steps) async {
    await _prefs.setInt(_keyTotalSteps, steps);
  }

  @override
  Future<void> setTodaySteps(int steps) async {
    await _prefs.setInt(_keyTodaySteps, steps);
    
    // 센서 기반 계산과의 정합성을 위해 baseline 조정
    final lastPedometer = _prefs.getInt(_keyLastPedometer) ?? 0;
    if (lastPedometer > 0) {
      await _prefs.setInt(_keyBaselinePedometer, lastPedometer - steps);
    }
  }

  @override
  Future<int> getTodaySteps() async {
    await _checkAndResetDailySteps();
    return _prefs.getInt(_keyTodaySteps) ?? 0;
  }

  /// 날짜 변경 체크 및 오늘 걸음수/Baseline 초기화
  Future<void> _checkAndResetDailySteps({int? currentPedometerValue}) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastDateStr = _prefs.getString(_keyLastUpdateDate) ?? "";

    if (todayStr != lastDateStr) {
      debugPrint(
        '[StepRepo] Date changed from $lastDateStr to $todayStr. Resetting today_steps.',
      );
      await _prefs.setInt(_keyTodaySteps, 0);
      await _prefs.setString(_keyLastUpdateDate, todayStr);
      
      // 마지막 알려진 센서값이 0이고 현재 센서값도 없다면, 
      // 아직 초기화 전이므로 baseline을 설정하지 않고 미룸 (updateFromPedometer에서 처리)
      final lastPedometer = _prefs.getInt(_keyLastPedometer) ?? 0;
      if (currentPedometerValue == null && lastPedometer == 0) {
        return;
      }

      final baseline = currentPedometerValue ?? lastPedometer;
      await _prefs.setInt(_keyBaselinePedometer, baseline);
    }
  }

  @override
  Future<StepData> updateFromPedometer(int pedometerValue) async {
    int lastPedometer = _prefs.getInt(_keyLastPedometer) ?? 0;

    // 1. 초기값 설정: 앱 설치 후 처음으로 센서값을 받을 때
    if (lastPedometer == 0) {
      debugPrint('[StepRepo] First run: initializing with sensor value $pedometerValue');
      await _prefs.setInt(_keyLastPedometer, pedometerValue);
      await _prefs.setInt(_keyBaselinePedometer, pedometerValue);
      await _prefs.setInt(_keyTodaySteps, 0);
      await _prefs.setInt(_keyTotalSteps, 0);
      
      final now = DateTime.now();
      await _prefs.setString(_keyLastUpdateDate, "${now.year}-${now.month}-${now.day}");
      
      return StepData(todaySteps: 0, totalSteps: 0);
    }

    // 2. 날짜 갱신 여부 체크: 날짜가 바뀌면 전달받은 값을 Baseline으로 설정
    await _checkAndResetDailySteps(currentPedometerValue: pedometerValue);

    int totalSteps = _prefs.getInt(_keyTotalSteps) ?? 0;
    int baselinePedometer = _prefs.getInt(_keyBaselinePedometer) ?? pedometerValue;

    // 3. 기기 재부팅 또는 센서 오류(센서값이 이전 값보다 작아지는 경우) 보정
    if (pedometerValue < lastPedometer) {
      debugPrint('[StepRepo] Reboot detected or sensor reset. Adjusting baseline.');
      int currentTodaySteps = _prefs.getInt(_keyTodaySteps) ?? 0;
      baselinePedometer = pedometerValue - currentTodaySteps;
      await _prefs.setInt(_keyBaselinePedometer, baselinePedometer);
    }

    // 4. 누적 걸음수(Total) 계산 로직
    int delta = pedometerValue - lastPedometer;
    if (delta > 0) {
      totalSteps += delta;
      await _prefs.setInt(_keyTotalSteps, totalSteps);
    }

    // 5. 오늘 걸음수 계산: 현재 센서값 - 오늘 자정 시점 센서값 (음수 방어)
    int calculatedToday = pedometerValue - baselinePedometer;
    if (calculatedToday < 0) calculatedToday = 0;
    
    await _prefs.setInt(_keyTodaySteps, calculatedToday);
    await _prefs.setInt(_keyLastPedometer, pedometerValue);

    return StepData(todaySteps: calculatedToday, totalSteps: totalSteps);
  }

  @override
  Future<void> clearSteps() async {
    await _prefs.remove(_keyTotalSteps);
    await _prefs.remove(_keyTodaySteps);
    await _prefs.remove(_keyLastUpdateDate);
    await _prefs.remove(_keyLastPedometer);
    await _prefs.remove(_keyBaselinePedometer);
  }
}

