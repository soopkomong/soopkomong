import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

// 실시간으로 친구 요청 목록 제공하는 StreamProvider
final friendRequestProvider = StreamProvider<List<FriendRequest>>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  
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
