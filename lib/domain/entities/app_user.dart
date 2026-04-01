import 'package:soopkomong/domain/entities/soopkomon.dart';

class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? socialPhotoUrl;

  final String? providerId; // 로그인 제공자 ID (google.com, apple.com, oidc.kakao 등)

  // 만보기 관련 필드
  final int totalSteps; // 현재 총 걸음 수
  final DateTime? lastStepUpdateAt; // 마지막으로 업데이트 된 시각

  // 획득한 캐릭터 리스트
  final List<Soopkomon> acquiredCharacters;

  // 친구 목록 (ID 리스트)
  final List<String> friends;
  final Map<String, DateTime> friendships;

  final String? userCode;
  final bool hasCharacter; // 캐릭터 생성 여부
  final bool hasName; // 이름 설정 여부
  final Map<String, dynamic>? characterSettings; // 캐릭터 파츠 설정 (머리, 얼굴, 옷 등)
  final bool wasReentry; // 탈퇴 후 14일 이내 재로그인 여부
  final List<int> unlockedParkIds; // 잠금 해제된 공원 ID 리스트
  final DateTime? createdAt; // 가입일
  final DateTime? deletedAt; // 탈퇴 신청일
  final bool hasSeenTutorial;

  AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.socialPhotoUrl,
    this.userCode,
    this.hasCharacter = false,
    this.hasName = false,
    this.hasSeenTutorial = false,
    this.characterSettings,
    this.totalSteps = 0,
    this.lastStepUpdateAt,
    this.createdAt,
    this.deletedAt,
    this.wasReentry = false,
    this.unlockedParkIds = const [],
    this.acquiredCharacters = const [],
    this.friends = const [],
    this.friendships = const {},
    this.providerId,
  });
}
