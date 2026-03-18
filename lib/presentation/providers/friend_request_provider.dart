import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

// 실시간으로 친구 요청 목록 제공하는 StreamProvider
// 실시간으로 '대기 중'인 친구 요청 목록만 제공 (친구 목록 페이지용)
final friendRequestProvider = StreamProvider<List<FriendRequest>>((ref) {
  final userAsyncValue = ref.watch(userProvider);
  final user = userAsyncValue.value;

  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('friend_requests')
      .where('receiverId', isEqualTo: user.id)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => FriendRequest.fromFirestore(doc))
            .toList();
      });
});

// 모든 상태의 친구 요청 목록 제공 (알림 페이지 이력용)
final friendRequestHistoryProvider = StreamProvider<List<FriendRequest>>((ref) {
  final userAsyncValue = ref.watch(userProvider);
  final user = userAsyncValue.value;

  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('friend_requests')
      .where('receiverId', isEqualTo: user.id)
      .snapshots()
      .map((snapshot) {
        final requests = snapshot.docs
            .map((doc) => FriendRequest.fromFirestore(doc))
            .toList();
        // 메모리에서 정렬 (인덱스 생성 지연 방지)
        requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return requests;
      });
});
