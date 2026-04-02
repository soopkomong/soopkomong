import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/data/repositories/step_repository_impl.dart';

void main() {
  late StepRepositoryImpl repository;

  setUp(() async {
    // 테스트용 mock 초기화
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = StepRepositoryImpl(prefs);
  });

  group('StepRepositoryImpl Tests', () {
    test('getTotalSteps returns 0 initially', () async {
      final total = await repository.getTotalSteps();
      expect(total, 0);
    });

    test('getTodaySteps returns 0 initially', () async {
      final today = await repository.getTodaySteps();
      expect(today, 0);
    });

    test('updateFromPedometer handles brand new user with huge sensor value (First Join)', () async {
      // 1. 센서값이 이미 40,000,000인 상태에서 처음 가입함 (첫 호출)
      final firstUpdate = await repository.updateFromPedometer(40000000);
      
      // 결과는 무조건 0보여야 함 (기준값으로만 설정)
      expect(firstUpdate.totalSteps, 0);
      expect(firstUpdate.todaySteps, 0);

      // 2. 이후 150보 더 걸음 (센서 40,000,150)
      final secondUpdate = await repository.updateFromPedometer(40000150);
      expect(secondUpdate.totalSteps, 150);
      expect(secondUpdate.todaySteps, 150);
    });

    test('updateFromPedometer initializes to 0 on first call and increments correctly', () async {
      // 1. 초기 100 걸음 감지 (기준점으로만 설정되어야 함)
      final firstUpdate = await repository.updateFromPedometer(100);
      expect(firstUpdate.totalSteps, 0);
      expect(firstUpdate.todaySteps, 0);

      // 2. 추가 50 걸음 (총 150 - 100 = 50)
      final secondUpdate = await repository.updateFromPedometer(150);
      expect(secondUpdate.totalSteps, 50);
      expect(secondUpdate.todaySteps, 50);
    });

    test('updateFromPedometer handles reboot detection properly (pedometer value drops)', () async {
      // 1. 처음엔 100 걸음 (기준점 100, 걸음수 0)
      await repository.updateFromPedometer(100);
      // 2. 50걸음 더 걸음 (센서 150, 기준점 100, 걸음수 50)
      await repository.updateFromPedometer(150);
      
      // 3. 기기 재부팅으로 인해 pedometer 값이 초기화되어 0부터 다시 시작 후 30 걸음 걸음
      // delta가 음수이므로 totalSteps는 50으로 유지되어야 함 (lastPedometer만 30으로 갱신됨)
      final rebootUpdate = await repository.updateFromPedometer(30);
      
      expect(rebootUpdate.totalSteps, 50);
      expect(rebootUpdate.todaySteps, 50);

      // 4. 이후 10걸음 더 걸음 (센서 40 - 이전 30 = 10걸음 추가)
      final nextUpdate = await repository.updateFromPedometer(40);
      expect(nextUpdate.totalSteps, 60);
      expect(nextUpdate.todaySteps, 60);
    });

    test('getTodaySteps resets today_steps if the date has changed', () async {
      final prefs = await SharedPreferences.getInstance();
      
      // 강제로 내부에 어제 날짜와 이전 걸음 데이터 주입
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = "\${yesterday.year}-\${yesterday.month}-\${yesterday.day}";
      
      await prefs.setInt('total_accumulated_steps', 500);
      await prefs.setInt('today_steps', 200);
      await prefs.setString('last_step_update_date', yesterdayStr);
      await prefs.setInt('last_known_pedometer_value', 1000);

      // 함수를 호출할 때, 내부적으로 날짜 변경이 감지되어 당일 걸음이 초기화되어야 함
      final todaySteps = await repository.getTodaySteps();
      expect(todaySteps, 0); // 200에서 0으로 초기화되었는지 검증

      // 전체 걸음은 어제까지 누적된 500이 그대로 유지되어야 함
      final totalSteps = await repository.getTotalSteps();
      expect(totalSteps, 500);
    });

    test('clearSteps removes all step related data', () async {
      final prefs = await SharedPreferences.getInstance();
      
      await repository.updateFromPedometer(100); // 초기화
      await repository.updateFromPedometer(600); // 500걸음 누적
      
      expect(prefs.getInt('total_accumulated_steps'), 500);
      
      await repository.clearSteps();
      
      expect(prefs.getInt('total_accumulated_steps'), null);
      expect(prefs.getInt('today_steps'), null);
      expect(prefs.getString('last_step_update_date'), null);
      expect(prefs.getInt('last_known_pedometer_value'), null);
    });
  });
}
