import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';

// 실시간으로 친구 요청 목록 제공하는 StreamProvider
// 실시간으로 '대기 중'인 친구 요청 목록만 제공 (친구 목록 페이지용)
final friendRequestProvider = StreamProvider<List<FriendRequest>>((ref) {
  return ref.watch(userProvider).when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final friendRepo = ref.read(friendRepositoryProvider);
      return friendRepo.getPendingFriendRequests(user.id);
    },
    loading: () => Stream.value([]),
    error: (e, st) => Stream.error(e, st),
  );
});

// 모든 상태의 친구 요청 목록 제공 (알림 페이지 이력용)
final friendRequestHistoryProvider = StreamProvider<List<FriendRequest>>((ref) {
  return ref.watch(userProvider).when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final friendRepo = ref.read(friendRepositoryProvider);
      return friendRepo.getFriendRequestHistory(user.id);
    },
    loading: () => Stream.value([]),
    error: (e, st) => Stream.error(e, st),
  );
});
