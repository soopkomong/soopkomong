import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';

class FriendsViewModel extends AsyncNotifier<List<FriendModel>> {
  @override
  Future<List<FriendModel>> build() async {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) async {
        if (user == null) return [];

        final friendRepo = ref.read(friendRepositoryProvider);
        final friends = await friendRepo.getFriendsForUser(user);
        return friends;
      },
      loading: () => state.value ?? [],
      error: (e, st) => throw e,
    );
  }

  Future<FriendModel> getFriendModelByUserId(String userId) async {
    final friendRepo = ref.read(friendRepositoryProvider);
    return friendRepo.getFriendModelByUserId(userId);
  }

  // 친구 요청 보내기 기능
  Future<void> sendFriendRequest(String targetInput) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.sendFriendRequest(currentUser, targetInput);
  }

  // 친구 요청 수락
  Future<void> acceptFriendRequest(FriendRequest request) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.acceptFriendRequest(currentUser, request);
    
    // 수락 후 친구 목록 즉시 갱신
    ref.invalidateSelf();
  }

  // 친구 요청 거절
  Future<void> declineFriendRequest(String requestId) async {
    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.declineFriendRequest(requestId);
  }

  // 모든 대기 중인 친구 요청 알림 확인 처리
  Future<void> markAllPendingRequestsAsNotified() async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.markAllPendingRequestsAsNotified(currentUser.id);
  }

  // 친구 요청 알림 확인 처리 (팝업 노출 완료 표시)
  Future<void> markNotified(String requestId) async {
    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.markNotified(requestId);
  }

  // 알림(친구 요청) 삭제
  Future<void> deleteNotification(String requestId) async {
    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.deleteNotification(requestId);
  }

  Future<void> addFriend(String code) async {
    await sendFriendRequest(code);
  }

  // 친구 삭제
  Future<void> removeFriend(String friendId) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    final friendRepo = ref.read(friendRepositoryProvider);
    await friendRepo.removeFriend(currentUser.id, friendId);

    // UI 즉시 업데이트를 위해 리프레시
    ref.invalidateSelf();
  }
}

final friendsViewModelProvider =
    AsyncNotifierProvider<FriendsViewModel, List<FriendModel>>(() {
      return FriendsViewModel();
    });

// 내 정보를 위한 프로바이더 (실제 Auth 데이터 기반)
final myInfoProvider = Provider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

