import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';

class CheckHatchingUseCase {
  final SoopkomonRepository _soopkomonRepository;

  CheckHatchingUseCase(this._soopkomonRepository);

  /// 백그라운드 등에서 주기적으로 호출하여 유저의 미부화 알들이 부화 조건에 도달했는지 체크합니다.
  /// 조건에 도달한 캐릭터들은 상태를 업데이트합니다.
  /// 부화한 캐릭터들에 대한 알림 메시지 목록을 반환합니다.
  Future<List<String>> execute(String userId, int currentSteps) async {
    final unhatchedList = await _soopkomonRepository.getUnhatchedSoopkomons(userId);
    List<String> hatchNotifications = [];

    for (var soopkomon in unhatchedList) {
      final updatedSoopkomon = soopkomon.copyWith(currentTotalSteps: currentSteps);

      if (updatedSoopkomon.traveledSteps >= updatedSoopkomon.requiredSteps) {
        // 부화 처리
        await _soopkomonRepository.updateSoopkomonSteps(
          userId,
          soopkomon.instanceId,
          currentSteps,
        );
        await _soopkomonRepository.markSoopkomonAsHatched(
          userId,
          soopkomon.instanceId,
        );

        final parkName = soopkomon.discoveredSpotName.isNotEmpty 
            ? soopkomon.discoveredSpotName 
            : '생태공원';
        final petName = soopkomon.name;

        hatchNotifications.add(
          '$parkName에 $petName 숲코몽이 태어났어요! 도감에서 자세한 정보를 확인하세요!',
        );
      }
    }

    return hatchNotifications;
  }
}
