import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';
import 'package:soopkomong/domain/usecases/check_hatching_usecase.dart';

class MockSoopkomonRepository extends Mock implements SoopkomonRepository {}

void main() {
  late CheckHatchingUseCase useCase;
  late MockSoopkomonRepository mockRepo;

  setUp(() {
    mockRepo = MockSoopkomonRepository();
    useCase = CheckHatchingUseCase(mockRepo);
  });

  group('CheckHatchingUseCase', () {
    final now = DateTime.now();
    final String userId = 'user_123';

    test('should not hatch if required steps are not met', () async {
      // S등급은 10000걸음 필요. 현재 5000걸음 걸음. (stepsAtDiscovery 0, current = 5000)
      final soopkomon = Soopkomon(
        instanceId: 'inst_1',
        templateId: '001',
        name: '대왕몽',
        discoveredSpotId: 'spot1',
        discoveredSpotName: '서울숲',
        discoveredAddr: '성동구',
        discoveredAt: now,
        stepsAtDiscovery: 0,
        currentTotalSteps: 0,
        isHatched: false,
        grade: 'S',
      );

      when(
        () => mockRepo.getUserSoopkomons(userId),
      ).thenAnswer((_) => Stream.value([soopkomon]));

      when(
        () => mockRepo.updateSoopkomonSteps(any(), any(), any()),
      ).thenAnswer((_) async {});

      final hatchedList = await useCase.execute(userId, 5000);

      expect(hatchedList, isEmpty);
      verify(() => mockRepo.getUserSoopkomons(userId)).called(1);
      // 걸음수가 100보 이상 차이나면 동기화가 발생함
      verify(
        () => mockRepo.updateSoopkomonSteps(userId, 'inst_1', 5000),
      ).called(1);
      verifyNever(() => mockRepo.markSoopkomonAsHatched(any(), any()));
    });

    test(
      'should hatch and return notification if required steps are met',
      () async {
        // C등급은 1000걸음 필요. 현재 1200걸음 걸음. (stepsAtDiscovery 0, current = 1200)
        final soopkomon = Soopkomon(
          instanceId: 'inst_2',
          templateId: '002',
          name: '쪼꼬미',
          discoveredSpotId: 'spot2',
          discoveredSpotName: '보라매공원',
          discoveredAddr: '동작구',
          discoveredAt: now,
          stepsAtDiscovery: 0,
          currentTotalSteps: 0,
          isHatched: false,
          grade: 'C',
        );

        when(
          () => mockRepo.getUserSoopkomons(userId),
        ).thenAnswer((_) => Stream.value([soopkomon]));
        when(
          () => mockRepo.updateSoopkomonSteps(userId, 'inst_2', 1200),
        ).thenAnswer((_) async {});
        when(
          () => mockRepo.markSoopkomonAsHatched(userId, 'inst_2'),
        ).thenAnswer((_) async {});

        final hatchedList = await useCase.execute(userId, 1200);

        expect(hatchedList.length, 1);
        expect(hatchedList.first.isHatched, true);
        expect(hatchedList.first.name, '쪼꼬미');

        verify(() => mockRepo.getUserSoopkomons(userId)).called(1);
        // 루프 시작 시 sync(1회) + 부화 성공 후 최종 sync(1회) = 총 2회 호출됨
        verify(
          () => mockRepo.updateSoopkomonSteps(userId, 'inst_2', 1200),
        ).called(2);
        verify(
          () => mockRepo.markSoopkomonAsHatched(userId, 'inst_2'),
        ).called(1);
      },
    );
  });
}
