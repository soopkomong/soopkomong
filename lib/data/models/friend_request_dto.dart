import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';

class FriendRequestDto extends FriendRequest {
  FriendRequestDto({
    required super.id,
    required super.senderId,
    required super.senderName,
    super.senderPhotoUrl,
    required super.receiverId,
    required super.status,
    required super.notified,
    required super.timestamp,
  });

  factory FriendRequestDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parsedTime = DateTime.now();
    final rawTime = data['timestamp'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      try {
        final rawString = rawTime;
        try {
          final cleaned = rawString
              .replaceAll('년', '-')
              .replaceAll('월', '-')
              .replaceAll('일', '')
              .replaceAll(RegExp(r'\s+-\s*'), '-')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();

          parsedTime = DateTime.parse(cleaned);
        } catch (innerE) {
          parsedTime = DateTime.now();
        }
      } catch (e) {
        parsedTime = DateTime.now();
      }
    }

    return FriendRequestDto(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '익명',
      senderPhotoUrl: data['senderPhotoUrl'],
      receiverId: data['receiverId'] ?? '',
      status: parseStatus(data['status']),
      notified: data['notified'] ?? false,
      timestamp: parsedTime,
    );
  }

  static FriendRequestStatus parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'declined':
        return FriendRequestStatus.declined;
      case 'pending':
      default:
        return FriendRequestStatus.pending;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverId': receiverId,
      'status': status.name,
      'notified': notified,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
