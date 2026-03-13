import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Firestore 데이터베이스와 앱 사이 '친구 요청' 데이터 주고 받을 수 있도록
// 데이,터 모델 클래스 구현
enum FriendRequestStatus {
  pending,
  accepted,
  declined,
}

class FriendRequest {
  final String id; // Firestore 문서 고유 id
  final String senderId; // 친구 요청 id
  final String senderName; // 요청보낸 사람 이름
  final String receiverId; // 요청 받는 사람 id
  final FriendRequestStatus status; // 현재 상태 (대기/수락/거절)
  final DateTime timestamp; // 요청 생성 시간

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '익명', // 이름이 없으면 '익명 처리' 나중에 바꾸기
      receiverId: data['receiverId'] ?? '',
      status: _parseStatus(data['status']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static FriendRequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'declined':
        return FriendRequestStatus.declined;
      case 'pending':
      default:
        return FriendRequestStatus.pending; // 기본 값은 '대기 중'
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
