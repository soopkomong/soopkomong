import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';

/// 숲코몽 및 관련 데이터를 처리하는 리포지토리 인터페이스
abstract class SoopkomonRepository {
  /// 모든 숲코몽 템플릿 로드 (언어 설정 반영)
  Future<List<SoopkomonTemplate>> getSoopkomonTemplates({
    AppLocale locale = AppLocale.ko,
  });

  /// 모든 공원 위치 데이터 로드 (언어 설정 반영)
  Future<List<Location>> getLocations({AppLocale locale = AppLocale.ko});

  /// 특정 petId가 등록된 공원 이름 목록 조회 (언어 설정 반영)
  Future<List<String>> getParkTitlesByPetId(
    String petId, {
    AppLocale locale = AppLocale.ko,
  });

  /// 특정 사용자가 획득한 캐릭터 목록 로드 (실시간)
  Stream<List<Soopkomon>> getUserSoopkomons(String userId);

  /// 새로운 캐릭터 획득 기록
  Future<void> addSoopkomon(String userId, Soopkomon soopkomon);

  /// 캐릭터 누적 걸음수 업데이트
  Future<void> updateSoopkomonSteps(
    String userId,
    String instanceId,
    int steps,
  );

  /// 캐릭터 부화 상태 업데이트
  Future<void> markSoopkomonAsHatched(String userId, String instanceId);
}
