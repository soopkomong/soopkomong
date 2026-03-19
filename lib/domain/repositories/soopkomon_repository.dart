import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';

/// 숲코몽 및 관련 데이터를 처리하는 리포지토리 인터페이스
abstract class SoopkomonRepository {
  /// 모든 숲코몽 템플릿 로드
  Future<List<SoopkomonTemplate>> getSoopkomonTemplates();

  /// 모든 공원 위치 데이터 로드
  Future<List<Location>> getLocations();

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
