import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';

abstract class FriendRepository {
  Future<List<FriendModel>> getFriendsForUser(AppUser user);
  Future<FriendModel> getFriendModelByUserId(String userId);

  Future<void> sendFriendRequest(AppUser currentUser, String targetInput);
  Future<void> acceptFriendRequest(AppUser currentUser, FriendRequest request);
  Future<void> declineFriendRequest(String requestId);

  Stream<List<FriendRequest>> getPendingFriendRequests(String userId);
  Stream<List<FriendRequest>> getFriendRequestHistory(String userId);

  Stream<AppUser> getUserStream(String userId);

  Future<void> markAllPendingRequestsAsNotified(String currentUserId);
  Future<void> markNotified(String requestId);
  Future<void> deleteNotification(String requestId);

  Future<void> removeFriend(String currentUserId, String friendId);
}
