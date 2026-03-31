import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soopkomong/domain/entities/app_user.dart';

class AppUserDto extends AppUser {
  AppUserDto({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.socialPhotoUrl,
    super.userCode,
    super.hasCharacter = false,
    super.hasName = false,
    super.hasSeenTutorial = false,
    super.characterSettings,
    super.totalSteps = 0,
    super.lastStepUpdateAt,
    super.createdAt,
    super.deletedAt,
    super.wasReentry = false,
    super.acquiredCharacters = const [],
    super.friends = const [],
    super.friendships = const {},
    super.providerId,
  });

  factory AppUserDto.fromFirebaseContext(User? user, DocumentSnapshot? doc) {
    if (user == null) {
      throw Exception('Cannot create AppUserDto from null Firebase User');
    }

    Map<String, dynamic>? data = doc?.data() as Map<String, dynamic>?;

    final Map<String, dynamic> rawFriendships =
        data?['friendships'] as Map<String, dynamic>? ?? {};
    final Map<String, DateTime> friendshipsMap = {};
    rawFriendships.forEach((key, value) {
      if (value is Timestamp) {
        friendshipsMap[key] = value.toDate();
      }
    });

    return AppUserDto(
      id: user.uid,
      email: user.email,
      displayName: data?['displayName'],
      photoUrl: data?['photoUrl'], // Only from Firestore (Character image)
      socialPhotoUrl: data?['socialPhotoUrl'] ?? user.photoURL, // Fallback to social photo
      userCode: data?['user_code'],
      hasCharacter: data?['has_character'] ?? false,
      hasName: data?['has_name'] ?? false,
      hasSeenTutorial: data?['has_seen_tutorial'] ?? false,
      characterSettings: data?['character_settings'],
      totalSteps: data?['totalSteps'] ?? 0,
      lastStepUpdateAt: data?['lastStepUpdateAt'] != null
          ? (data?['lastStepUpdateAt'] as Timestamp).toDate()
          : null,
      createdAt: data?['createdAt'] != null
          ? (data?['createdAt'] as Timestamp).toDate()
          : null,
      deletedAt: data?['deletedAt'] != null
          ? (data?['deletedAt'] as Timestamp).toDate()
          : null,
      wasReentry: data?['wasReentry'] ?? false,
      friends: List<String>.from(data?['friends'] ?? []),
      friendships: friendshipsMap,
      providerId: user.providerData.isNotEmpty
          ? user.providerData[0].providerId
          : null,
    );
  }
}
