import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/domain/repositories/step_repository.dart';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class StepRepositoryImpl implements StepRepository {
  static const String _keyTotalSteps = 'total_accumulated_steps';
  static const String _keyTodaySteps = 'today_steps';
  static const String _keyLastUpdateDate = 'last_step_update_date';
  static const String _keyLastPedometer = 'last_known_pedometer_value';

  final SharedPreferences _prefs;
  final Health _health = Health();

  StepRepositoryImpl(this._prefs);

  @override
  Future<int> getTotalSteps() async {
    return _prefs.getInt(_keyTotalSteps) ?? 0;
  }

  @override
  Future<int> getTodaySteps() async {
    await _checkAndResetDailySteps();
    return _prefs.getInt(_keyTodaySteps) ?? 0;
  }

  /// 날짜가 변경되었는지 확인하고 필요시 오늘 걸음수를 초기화합니다.
  Future<void> _checkAndResetDailySteps() async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastDateStr = _prefs.getString(_keyLastUpdateDate) ?? "";

    if (todayStr != lastDateStr) {
      debugPrint(
        '[StepRepo] Date changed from $lastDateStr to $todayStr. Resetting today_steps.',
      );
      await _prefs.setInt(_keyTodaySteps, 0);
      await _prefs.setString(_keyLastUpdateDate, todayStr);
    }
  }

  @override
  Future<StepData> updateFromPedometer(int pedometerValue) async {
    await _checkAndResetDailySteps();

    int totalSteps = _prefs.getInt(_keyTotalSteps) ?? 0;
    int todaySteps = _prefs.getInt(_keyTodaySteps) ?? 0;
    int lastPedometer = _prefs.getInt(_keyLastPedometer) ?? 0;

    // 재부팅 감지
    if (pedometerValue < lastPedometer) {
      debugPrint('[StepRepo] Reboot detected. Resetting pedometer baseline.');
      lastPedometer = 0;
    }

    int delta = pedometerValue - lastPedometer;
    if (delta > 0) {
      totalSteps += delta;
      todaySteps += delta;
      await _prefs.setInt(_keyTotalSteps, totalSteps);
      await _prefs.setInt(_keyTodaySteps, todaySteps);
    }

    await _prefs.setInt(_keyLastPedometer, pedometerValue);
    return StepData(todaySteps: todaySteps, totalSteps: totalSteps);
  }

  @override
  Future<StepData> syncWithHealthApp() async {
    try {
      final types = [HealthDataType.STEPS];

      bool requested = await _health.requestAuthorization(types);
      if (!requested) {
        return StepData(
          todaySteps: await getTodaySteps(),
          totalSteps: await getTotalSteps(),
        );
      }

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      int? healthSteps = await _health.getTotalStepsInInterval(midnight, now);

      if (healthSteps != null) {
        await _checkAndResetDailySteps();
        int currentToday = _prefs.getInt(_keyTodaySteps) ?? 0;

        if (healthSteps > currentToday) {
          int diff = healthSteps - currentToday;
          int currentTotal = _prefs.getInt(_keyTotalSteps) ?? 0;

          await _prefs.setInt(_keyTodaySteps, healthSteps);
          await _prefs.setInt(_keyTotalSteps, currentTotal + diff);

          return StepData(
            todaySteps: healthSteps,
            totalSteps: currentTotal + diff,
          );
        }
      }
    } catch (e) {
      debugPrint('[StepRepo] Health Sync Error: $e');
    }

    return StepData(
      todaySteps: await getTodaySteps(),
      totalSteps: await getTotalSteps(),
    );
  }

  @override
  Future<void> clearSteps() async {
    await _prefs.remove(_keyTotalSteps);
    await _prefs.remove(_keyTodaySteps);
    await _prefs.remove(_keyLastUpdateDate);
    await _prefs.remove(_keyLastPedometer);
  }
}
