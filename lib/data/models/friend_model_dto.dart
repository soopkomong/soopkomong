import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';

class FriendModelDto extends FriendModel {
  FriendModelDto({
    required super.id,
    required super.name,
    super.photoUrl,
    super.characterSettings,
    super.totalSteps,
    super.friendedAt,
  });

  factory FriendModelDto.fromFirestore(
    DocumentSnapshot doc, {
    DateTime? friendedAtOverride,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FriendModelDto(
      id: doc.id,
      name: data['displayName'] ?? '이름 없음',
      photoUrl: data['photoUrl'],
      characterSettings: data['character_settings'] as Map<String, dynamic>?,
      totalSteps: (data['totalSteps'] as num?)?.toInt() ?? 0,
      friendedAt:
          friendedAtOverride ??
          (data['friendedAt'] != null
              ? (data['friendedAt'] as Timestamp).toDate()
              : null),
    );
  }
}
