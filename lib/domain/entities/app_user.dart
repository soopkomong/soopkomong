import 'package:soopkomong/domain/entities/soopkomon.dart';

class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  // 만보기 관련 필드
  final int totalSteps; // 현재 총 걸음 수
  final DateTime? lastStepUpdateAt; // 마지막으로 업데이트 된 시각

  // 획득한 캐릭터 리스트
  final List<Soopkomon> acquiredCharacters;

  AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.totalSteps = 0,
    this.lastStepUpdateAt,
    this.acquiredCharacters = const [],
  });
}
