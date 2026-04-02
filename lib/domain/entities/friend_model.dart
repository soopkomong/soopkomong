class FriendModel {
  final String id; // 친구의 고유 id
  final String name; // 친구 이름
  final String? photoUrl; // 프로필 사진 URL
  final Map<String, dynamic>? characterSettings; // 캐릭터 파츠 설정

  final int totalSteps; // 친구의 총 걸음 수
  final DateTime? friendedAt; // 친구가 된 날짜

  FriendModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.characterSettings,
    this.totalSteps = 0,
    this.friendedAt,
  });
}
