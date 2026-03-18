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
  final String senderTemplateId; // 보낸 사람의 캐릭터 템플릿 ID
  final String receiverId; // 요청 받는 사람 id
  final FriendRequestStatus status; // 현재 상태 (대기/수락/거절)
  final DateTime timestamp; // 요청 생성 시간

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderTemplateId,
    required this.receiverId,
    required this.status,
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

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // timestamp 파싱 로직: Timestamp 객체이거나 String 일치 처리
    DateTime parsedTime = DateTime.now();
    final rawTime = data['timestamp'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      // "2026년 3월 17일 20:00" 같은 형태가 들어올 경우 파싱 처리 시도
      try {
        final rawString = rawTime;
        // intl 패키지의 DateFormat을 이용한 명시적 파싱 체계 적용
        // "yyyy년 M월 d일 HH:mm" 형태 가정 (공백에 유의)
        // 만약 형식이 일관되지 않다면 기본 파서를 먼저 시도
        try {
          // "년", "월" 등의 문맥을 제거해주는 방식 개선: 2026-03-17 20:00 형태로 강제 변환
          final cleaned = rawString
              .replaceAll('년', '-')
              .replaceAll('월', '-')
              .replaceAll('일', '')
              .replaceAll(RegExp(r'\s+-\s*'), '-') // 불필요한 공백 제거
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          
          parsedTime = DateTime.parse(cleaned);
        } catch (innerE) {
          // 최후의 수단으로 현재 시간 배정
          parsedTime = DateTime.now();
        }
      } catch (e) {
        parsedTime = DateTime.now();
      }
    }

    return FriendRequest(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '익명', // 이름이 없으면 '익명 처리' 나중에 바꾸기
      senderTemplateId: data['senderTemplateId'] ?? '001',
      receiverId: data['receiverId'] ?? '',
      status: _parseStatus(data['status']),
      timestamp: parsedTime,
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
      'senderTemplateId': senderTemplateId,
      'receiverId': receiverId,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
