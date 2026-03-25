import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/domain/repositories/step_repository.dart';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class StepRepositoryImpl implements StepRepository {
  static const String _keyTotalSteps = 'total_accumulated_steps';
  static const String _keyLastPedometer = 'last_known_pedometer_value';
  
  final SharedPreferences _prefs;
  final Health _health = Health();

  StepRepositoryImpl(this._prefs);

  @override
  Future<int> getTotalSteps() async {
    return _prefs.getInt(_keyTotalSteps) ?? 0;
  }

  @override
  Future<int> updateFromPedometer(int pedometerValue) async {
    int totalSteps = _prefs.getInt(_keyTotalSteps) ?? 0;
    int lastPedometer = _prefs.getInt(_keyLastPedometer) ?? 0;

    // 재부팅 감지: 현재 센서값이 마지막 저장값보다 작으면 누적을 중단하고 현재값을 새로운 기준으로 설정
    if (pedometerValue < lastPedometer) {
      debugPrint('[StepRepo] Reboot detected. Resetting pedometer baseline.');
      lastPedometer = 0; 
    }

    int delta = pedometerValue - lastPedometer;
    if (delta > 0) {
      totalSteps += delta;
      await _prefs.setInt(_keyTotalSteps, totalSteps);
    }

    await _prefs.setInt(_keyLastPedometer, pedometerValue);
    return totalSteps;
  }

  @override
  Future<int> syncWithHealthApp() async {
    try {
      final types = [HealthDataType.STEPS];
      
      // 권한 요청
      bool requested = await _health.requestAuthorization(types);
      if (!requested) return getTotalSteps();

      // 오늘 0시부터 현재까지의 데이터 가져오기
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      int? healthSteps = await _health.getTotalStepsInInterval(midnight, now);
      
      if (healthSteps != null) {
        int currentTotal = await getTotalSteps();
        
        // 건강 앱 데이터가 더 크다면 업데이트 (워치 데이터 등이 포함되었을 가능성)
        // 단, 오늘 하루치만 비교하는 것이 아니라 누적 시스템이므로 정합성 주의 필요
        // 여기서는 간단하게 시스템 누적치와의 차이를 보정하는 로직을 사용하거나
        // 건강 앱 데이터를 주 데이터원으로 삼는 방식으로 발전시킬 수 있음
        debugPrint('[StepRepo] Health App Steps: $healthSteps');
        
        // 실제 운영 시에는 '오늘의 걸음수'와 '누적 걸음수'를 분리 관리하는 것이 더 정확함
        // 일단은 현재 시스템에 맞춰 업데이트 로직 구성
      }
    } catch (e) {
      debugPrint('[StepRepo] Health Sync Error: $e');
    }
    return getTotalSteps();
  }

  @override
  Future<void> clearSteps() async {
    await _prefs.remove(_keyTotalSteps);
    await _prefs.remove(_keyLastPedometer);
  }
}
