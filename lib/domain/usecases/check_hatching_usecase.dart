import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';

class CheckHatchingUseCase {
  final SoopkomonRepository _soopkomonRepository;

  CheckHatchingUseCase(this._soopkomonRepository);

  /// 백그라운드 등에서 주기적으로 호출하여 유저의 미부화 알들이 부화 조건에 도달했는지 체크합니다.
  /// 조건에 도달한 캐릭터들은 상태를 업데이트합니다.
  /// 부화한 캐릭터 객체 목록을 반환합니다.
  Future<List<Soopkomon>> execute(String userId, int currentSteps) async {
    final allSoopkomons = await _soopkomonRepository
        .getUserSoopkomons(userId)
        .first;
    List<Soopkomon> hatchedSoopkomons = [];

    for (var soopkomon in allSoopkomons) {
      final updatedSoopkomon = soopkomon.copyWith(
        currentTotalSteps: currentSteps,
      );

      // 1. 걸음수 동기화 최적화 (100보 단위 또는 아직 동기화되지 않은 경우만)
      // UI에서 실시간 계산을 수행하므로 DB 업데이트는 간헐적으로 진행함
      final needsSync = (currentSteps - (soopkomon.currentTotalSteps)) >= 100;

      if (needsSync) {
        await _soopkomonRepository.updateSoopkomonSteps(
          userId,
          soopkomon.instanceId,
          currentSteps,
        );
      }

      // 2. 부화 조건 체크 (아직 알 상태인 경우만)
      if (!soopkomon.isHatched &&
          updatedSoopkomon.traveledSteps >= updatedSoopkomon.requiredSteps) {
        // 부화 처리 (이때는 즉시 DB 반영)
        await _soopkomonRepository.markSoopkomonAsHatched(
          userId,
          soopkomon.instanceId,
        );

        // 최종 걸음수 한 번 더 동기화
        await _soopkomonRepository.updateSoopkomonSteps(
          userId,
          soopkomon.instanceId,
          currentSteps,
        );

        hatchedSoopkomons.add(updatedSoopkomon.copyWith(isHatched: true));
      }
    }

    return hatchedSoopkomons;
  }
}
