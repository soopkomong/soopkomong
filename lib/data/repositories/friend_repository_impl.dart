import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/domain/repositories/friend_repository.dart';
import 'package:soopkomong/data/models/friend_model_dto.dart';
import 'package:soopkomong/data/models/friend_request_dto.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FirebaseFirestore _firestore;

  FriendRepositoryImpl(this._firestore);

  @override
  Future<List<FriendModel>> getFriendsForUser(AppUser user) async {
    final List<String> friendIds = user.friends;
    final Map<String, DateTime> friendships = user.friendships;

    if (friendIds.isEmpty) return [];

    final List<FriendModel> friends = [];

    for (var i = 0; i < friendIds.length; i += 30) {
      final chunk = friendIds.sublist(
        i,
        i + 30 > friendIds.length ? friendIds.length : i + 30,
      );
      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      friends.addAll(
        querySnapshot.docs.map((doc) {
          final friendedAt = friendships[doc.id];
          return FriendModelDto.fromFirestore(
            doc,
            friendedAtOverride: friendedAt,
          );
        }),
      );
    }

    // 추가된 순서대로 정렬 (friendIds 리스트의 인덱스 기준)
    friends.sort(
      (a, b) => friendIds.indexOf(a.id).compareTo(friendIds.indexOf(b.id)),
    );

    return friends;
  }

  @override
  Future<FriendModel> getFriendModelByUserId(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('유저를 찾을 수 없습니다.');
    return FriendModelDto.fromFirestore(doc);
  }

  @override
  Future<void> sendFriendRequest(AppUser currentUser, String targetInput) async {
    String targetId = targetInput.trim();

    // 1. 입력값이 user_code인지 확인하기 위해 Firestore 쿼리
    final userCodeQuery = await _firestore
        .collection('users')
        .where('user_code', isEqualTo: targetId.toUpperCase())
        .limit(1)
        .get();

    if (userCodeQuery.docs.isNotEmpty) {
      // 코드를 가진 유저를 찾았다면 해당 유저의 id(UID)를 타겟으로 설정
      targetId = userCodeQuery.docs.first.id;
    }

    if (currentUser.id == targetId) {
      throw Exception('자기 자신에게는 친구 요청을 보낼 수 없습니다.');
    }

    // 이미 친구인지 확인 (메모리의 currentUser 정보 활용)
    if (currentUser.friends.contains(targetId)) {
      throw Exception('이미 친구입니다.');
    }

    // 이미 보내진 요청이 있는지 확인
    final existingRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUser.id)
        .where('receiverId', isEqualTo: targetId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existingRequest.docs.isNotEmpty) {
      throw Exception('이미 친구 요청을 보냈습니다.');
    }

    // 상대방 존재 여부 확인 (UID로 검색)
    final targetDoc = await _firestore.collection('users').doc(targetId).get();
    if (!targetDoc.exists) {
      throw Exception('해당 코드 또는 ID의 유저를 찾을 수 없습니다.');
    }

    // 친구 요청 문서 생성 (photoUrl에 이미 아바타 정보가 포함되어 있음)
    final request = FriendRequestDto(
      id: '', // Firestore에서 자동 생성
      senderId: currentUser.id,
      senderName: currentUser.displayName ?? '익명',
      senderPhotoUrl: currentUser.photoUrl,
      receiverId: targetId,
      status: FriendRequestStatus.pending,
      notified: false,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('friend_requests').add(request.toFirestore());
  }

  @override
  Future<void> acceptFriendRequest(AppUser currentUser, FriendRequest request) async {
    // 본인에게 온 요청인지 확인 (ID 불일치 방지)
    if (request.receiverId != currentUser.id) {
      throw Exception('본인에게 온 친구 요청만 수락할 수 있습니다.');
    }

    if (request.id.isEmpty) {
      throw Exception('요청 ID가 유효하지 않습니다.');
    }

    final batch = _firestore.batch();

    // 1. 요청 상태 변경
    final requestRef = _firestore.collection('friend_requests').doc(request.id);
    batch.update(requestRef, {
      'status': 'accepted',
      'notified': true,
    });

    // 2. 내 친구 목록 및 날짜 추가
    final myRef = _firestore.collection('users').doc(currentUser.id);
    batch.update(myRef, {
      'friends': FieldValue.arrayUnion([request.senderId]),
      'friendships.${request.senderId}': FieldValue.serverTimestamp(),
    });

    // 3. 상대방 친구 목록 및 날짜 추가
    final senderRef = _firestore.collection('users').doc(request.senderId);
    batch.update(senderRef, {
      'friends': FieldValue.arrayUnion([currentUser.id]),
      'friendships.${currentUser.id}': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).update({
      'status': 'declined',
      'notified': true,
    });
  }

  @override
  Stream<List<FriendRequest>> getPendingFriendRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FriendRequestDto.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<FriendRequest>> getFriendRequestHistory(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => FriendRequestDto.fromFirestore(doc))
              .toList();
          requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return requests;
        });
  }

  @override
  Future<void> markAllPendingRequestsAsNotified(String currentUserId) async {
    final querySnapshot = await _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .where('notified', isEqualTo: false)
        .get();

    if (querySnapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'notified': true});
    }
    await batch.commit();
  }

  @override
  Future<void> markNotified(String requestId) async {
    await _firestore
        .collection('friend_requests')
        .doc(requestId)
        .update({'notified': true});
  }

  @override
  Future<void> deleteNotification(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  @override
  Future<void> removeFriend(String currentUserId, String friendId) async {
    final batch = _firestore.batch();

    // 1. 내 친구 목록 및 날짜 데이터 삭제
    final myRef = _firestore.collection('users').doc(currentUserId);
    batch.update(myRef, {
      'friends': FieldValue.arrayRemove([friendId]),
      'friendships.$friendId': FieldValue.delete(),
    });

    // 2. 상대방 친구 목록 및 날짜 데이터 삭제
    final friendRef = _firestore.collection('users').doc(friendId);
    batch.update(friendRef, {
      'friends': FieldValue.arrayRemove([currentUserId]),
      'friendships.$currentUserId': FieldValue.delete(),
    });

    // 3. 관련 친구 요청 문서 삭제 (재신청이 가능하도록 정리)
    final requestsQuery = await _firestore
        .collection('friend_requests')
        .where('senderId', whereIn: [currentUserId, friendId])
        .get();

    for (var doc in requestsQuery.docs) {
      final data = doc.data();
      final senderId = data['senderId'];
      final receiverId = data['receiverId'];

      // 내 ID와 상대방 ID가 서로 교차되어 있는지 확인 (A->B or B->A)
      if ((senderId == currentUserId && receiverId == friendId) ||
          (senderId == friendId && receiverId == currentUserId)) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }
}
