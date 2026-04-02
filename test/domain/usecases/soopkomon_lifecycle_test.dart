import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';
import 'package:soopkomong/domain/usecases/check_hatching_usecase.dart';

class MockSoopkomonRepository extends Mock implements SoopkomonRepository {}

void main() {
  late CheckHatchingUseCase checkHatchingUseCase;
  late MockSoopkomonRepository mockRepo;

  setUp(() {
    mockRepo = MockSoopkomonRepository();
    checkHatchingUseCase = CheckHatchingUseCase(mockRepo);

    // 기본 stubbing
    registerFallbackValue(
      Soopkomon(
        instanceId: '',
        templateId: '',
        name: '',
        discoveredSpotId: '',
        discoveredSpotName: '',
        discoveredAddr: '',
        discoveredAt: DateTime.now(),
        stepsAtDiscovery: 0,
        currentTotalSteps: 0,
      ),
    );
  });

  group('Soopkomon Lifecycle Integration Test', () {
    final String userId = 'test_user_001';
    final now = DateTime.now();

    test('공원 발견 -> 획득 -> 걸음수 증가 -> 부화로 이어지는 전체 흐름 검증', () async {
      // 1. 공원(서울숲)에서 숲코몽 알을 발견하여 획득함 (Discovery/Obtain)
      // 초기 상태: 5000보를 걸은 상태에서 알을 발견함
      final initialSteps = 5000;
      final soopkomon = Soopkomon(
        instanceId: 'inst_lifecycle_1',
        templateId: '001',
        name: '대왕몽',
        discoveredSpotId: 'seoul_forest_01',
        discoveredSpotName: '서울숲',
        discoveredAddr: '성동구 성수동',
        discoveredAt: now,
        stepsAtDiscovery: initialSteps, // 발견 시점의 걸음수
        currentTotalSteps: initialSteps,
        isHatched: false,
        grade: 'C', // C등급은 부화에 1000보 필요
      );

      when(() => mockRepo.addSoopkomon(userId, any())).thenAnswer((_) async {});

      // 실제 획득 로직 시뮬레이션
      await mockRepo.addSoopkomon(userId, soopkomon);
      verify(() => mockRepo.addSoopkomon(userId, any())).called(1);

      // 2. 시간이 흘러 유저가 1500보를 더 걸음 (총 6500보)
      // 부화 조건: currentSteps (6500) - stepsAtDiscovery (5000) = 1500 >= 1000 (부화 성공!)
      final updatedSteps = 6500;

      // Repository 상태 시뮬레이션: DB에 해당 소프쿠몽이 저장되어 있는 상태
      when(
        () => mockRepo.getUserSoopkomons(userId),
      ).thenAnswer((_) => Stream.value([soopkomon]));

      when(
        () => mockRepo.updateSoopkomonSteps(userId, any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockRepo.markSoopkomonAsHatched(userId, any()),
      ).thenAnswer((_) async {});

      // 3. 부화 체크 유스케이스 실행 (백그라운드 또는 걸음수 업데이트 시 호출됨)
      final hatchedList = await checkHatchingUseCase.execute(
        userId,
        updatedSteps,
      );

      // 4. 검증
      // 부화된 목록에 1마리가 포함되어 있어야 함
      expect(hatchedList.length, 1);
      expect(hatchedList.first.instanceId, 'inst_lifecycle_1');
      expect(hatchedList.first.isHatched, true);

      // DB 업데이트가 정상적으로 호출되었는지 확인
      // updateSoopkomonSteps는 루프 시작(최적화) 시와 부화 성공 시 각각 호출될 수 있음
      verify(
        () => mockRepo.markSoopkomonAsHatched(userId, 'inst_lifecycle_1'),
      ).called(1);
      verify(
        () => mockRepo.updateSoopkomonSteps(
          userId,
          'inst_lifecycle_1',
          updatedSteps,
        ),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
