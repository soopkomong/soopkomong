import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

// 실시간으로 친구 요청 목록 제공하는 StreamProvider
final friendRequestProvider = StreamProvider<List<FriendRequest>>((ref) {
  // authRepositoryProvider 내부의 currentUser 속성은 변경 알림을 방출하지 않으므로,
  // 정상적인 반응형 업데이트를 위해 userProvider(혹은 authStateChangesProvider)를 watch 해야 합니다.
  final userAsyncValue = ref.watch(userProvider);
  final user = userAsyncValue.value;

  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('friend_requests')
      .where('receiverId', isEqualTo: user.id)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => FriendRequest.fromFirestore(doc))
            .toList();
      });
});
