import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String id; // 친구의 고유 id
  final String name; // 친구 이름
  final String? photoUrl; // 프로필 사진 URL
  final String characterTemplateId;
  final Map<String, dynamic>? characterSettings; // 캐릭터 파츠 설정
  
  final int leafMax; // 최대 레벨 (UI 표시용)
  final int pawMax; // 최대 캐릭터 (UI 표시용)

  final int totalSteps; // 친구의 총 걸음 수
  final DateTime? friendedAt; // 친구가 된 날짜

  FriendModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.characterTemplateId,
    this.characterSettings,
    required this.leafMax,
    required this.pawMax,
    this.totalSteps = 0,
    this.friendedAt,
  });

  factory FriendModel.fromFirestore(DocumentSnapshot doc, {DateTime? friendedAtOverride}) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FriendModel(
      id: doc.id,
      name: data['displayName'] ?? '이름 없음',
      photoUrl: data['photoUrl'],
      characterTemplateId: data['templateId'] ?? '007',
      characterSettings: data['character_settings'] as Map<String, dynamic>?,
      leafMax: (data['leafMax'] as num?)?.toInt() ?? 50,
      pawMax: (data['pawMax'] as num?)?.toInt() ?? 30,
      totalSteps: (data['totalSteps'] as num?)?.toInt() ?? 0,
      friendedAt: friendedAtOverride ?? (data['friendedAt'] != null
          ? (data['friendedAt'] as Timestamp).toDate()
          : null),
    );
  }
}
