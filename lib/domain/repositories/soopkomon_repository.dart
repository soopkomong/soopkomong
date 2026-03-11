import 'package:soopkomong/domain/entities/soopkomon_template.dart';

/// 숲코몽 및 관련 데이터를 처리하는 리포지토리 인터페이스
abstract class SoopkomonRepository {
  /// 모든 숲코몽 템플릿 로드
  Future<List<SoopkomonTemplate>> getSoopkomonTemplates();

  /// 공원 데이터 로드
  Future<List<dynamic>> getLocations();
}
