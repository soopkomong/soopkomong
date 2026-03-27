// Firebase Firestore 등 특정 데이터베이스에 의존하지 않는 순수 '친구 요청' 도메인 엔티티
enum FriendRequestStatus { pending, accepted, declined }

class FriendRequest {
  final String id; // 문서 고유 id
  final String senderId; // 친구 요청 id
  final String senderName; // 요청보낸 사람 이름
  final String? senderPhotoUrl; // 요청보낸 사람 사진 URL
  final String receiverId; // 요청 받는 사람 id
  final FriendRequestStatus status; // 현재 상태 (대기/수락/거절)
  final bool notified; // 알림(팝업) 노출 여부
  final DateTime timestamp; // 요청 생성 시간

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.receiverId,
    required this.status,
    required this.notified,
    required this.timestamp,
  });

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.isNegative || difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}월 ${timestamp.day}일';
    }
  }
}
