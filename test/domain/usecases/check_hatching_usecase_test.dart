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

      when(() => mockRepo.getUnhatchedSoopkomons(userId))
          .thenAnswer((_) async => [soopkomon]);

      final notifications = await useCase.execute(userId, 5000);

      expect(notifications, isEmpty);
      verify(() => mockRepo.getUnhatchedSoopkomons(userId)).called(1);
      verifyNever(() => mockRepo.updateSoopkomonSteps(any(), any(), any()));
      verifyNever(() => mockRepo.markSoopkomonAsHatched(any(), any()));
    });

    test('should hatch and return notification if required steps are met', () async {
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

      when(() => mockRepo.getUnhatchedSoopkomons(userId))
          .thenAnswer((_) async => [soopkomon]);
      when(() => mockRepo.updateSoopkomonSteps(userId, 'inst_2', 1200))
          .thenAnswer((_) async {});
      when(() => mockRepo.markSoopkomonAsHatched(userId, 'inst_2'))
          .thenAnswer((_) async {});

      final notifications = await useCase.execute(userId, 1200);

      expect(notifications.length, 1);
      expect(notifications.first, '보라매공원에 쪼꼬미 숲코몽이 태어났어요! 도감에서 자세한 정보를 확인하세요!');
      
      verify(() => mockRepo.getUnhatchedSoopkomons(userId)).called(1);
      verify(() => mockRepo.updateSoopkomonSteps(userId, 'inst_2', 1200)).called(1);
      verify(() => mockRepo.markSoopkomonAsHatched(userId, 'inst_2')).called(1);
    });
  });
}
