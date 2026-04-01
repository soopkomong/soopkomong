import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/domain/repositories/friend_repository.dart';
import 'package:soopkomong/data/models/app_user_dto.dart';
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

    // 이미 보내진 요청이 있는지 확인 (내가 보낸 것)
    final sentRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUser.id)
        .where('receiverId', isEqualTo: targetId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (sentRequest.docs.isNotEmpty) {
      throw Exception('이미 친구 요청을 보냈습니다.');
    }

    // 상대방이 나에게 보낸 요청이 있는지 확인 (양방향 중복 방지)
    final receivedRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: targetId)
        .where('receiverId', isEqualTo: currentUser.id)
        .where('status', isEqualTo: 'pending')
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      throw Exception('상대방으로부터 받은 친구 요청이 이미 있습니다. 알림 창에서 수락해 주세요.');
    }

    // 상대방 존재 여부 확인 (UID로 검색)
    final targetDoc = await _firestore.collection('users').doc(targetId).get();
    if (!targetDoc.exists) {
      throw Exception('해당 코드 또는 ID의 유저를 찾을 수 없습니다.');
    }

    // 보낸 사람의 최신 정보를 Firestore에서 다시 조회하여 데이터 정합성 확보
    final senderDoc = await _firestore.collection('users').doc(currentUser.id).get();
    final senderData = senderDoc.data();
    
    final String senderName = senderData?['displayName'] ?? currentUser.displayName ?? '익명';
    // 사진 우선순위: 캐릭터 아바타(photoUrl) > 소셜 프로필(socialPhotoUrl) > null
    final String? senderPhotoUrl = (senderData?['photoUrl'] as String?)?.isNotEmpty == true 
        ? senderData!['photoUrl'] 
        : (senderData?['socialPhotoUrl'] as String?)?.isNotEmpty == true
            ? senderData!['socialPhotoUrl']
            : currentUser.photoUrl;

    // 친구 요청 문서 생성
    final request = FriendRequestDto(
      id: '', // Firestore에서 자동 생성
      senderId: currentUser.id,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: targetId,
      status: FriendRequestStatus.pending,
      notified: false,
      timestamp: DateTime.now(),
    );

    try {
      await _firestore.collection('friend_requests').add(request.toFirestore());
      debugPrint('[친구신청] 성공: ${currentUser.id} -> $targetId');
    } catch (e) {
      debugPrint('[친구신청] 실패: $e');
      throw Exception('친구 요청을 보내는 중 오류가 발생했습니다: $e');
    }
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

    // 2. 내 친구 목록 및 날짜 추가 (update & dot notation 사용으로 기존 데이터 보존)
    final myRef = _firestore.collection('users').doc(currentUser.id);
    batch.update(myRef, {
      'friends': FieldValue.arrayUnion([request.senderId]),
      'friendships.${request.senderId}': FieldValue.serverTimestamp(),
    });

    // 3. 상대방 친구 목록 및 날짜 추가 (update & dot notation 사용으로 기존 데이터 보존)
    final senderRef = _firestore.collection('users').doc(request.senderId);
    batch.update(senderRef, {
      'friends': FieldValue.arrayUnion([currentUser.id]),
      'friendships.${currentUser.id}': FieldValue.serverTimestamp(),
    });

    try {
      debugPrint('[친구수락] 배치 커밋 시도: ${request.id}');
      await batch.commit();
      debugPrint('[친구수락] 성공: ${request.senderId} <-> ${currentUser.id}');
    } catch (e) {
      debugPrint('[친구수락] 실패(Batch Commit): $e');
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          throw Exception('친구 요청 수락 권한이 없습니다. 관리자에게 보안 규칙 설정을 확인해 주세요.');
        } else if (e.code == 'not-found') {
          throw Exception('친구 요청 수락에 실패했습니다. 유저 정보가 존재하지 않습니다.');
        }
      }
      throw Exception('친구 요청 수락 중 오류가 발생했습니다: $e');
    }
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
  Stream<AppUser> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            throw Exception('유저를 찾을 수 없습니다.');
          }
          return AppUserDto.fromFirestore(snapshot).toEntity();
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

    // 2. 상대방 친구 목록 및 날짜 데이터 삭제 (규칙 수정으로 가능)
    final friendRef = _firestore.collection('users').doc(friendId);
    batch.update(friendRef, {
      'friends': FieldValue.arrayRemove([currentUserId]),
      'friendships.$currentUserId': FieldValue.delete(),
    });

    // 3. 관련 친구 요청 문서 완전 삭제 (재신청이 가능하도록 정리)
    // A->B 요청과 B->A 요청 모두 삭제
    final requestsAtoB = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: friendId)
        .get();

    final requestsBtoA = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: friendId)
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    for (var doc in requestsAtoB.docs) {
      batch.delete(doc.reference);
    }
    for (var doc in requestsBtoA.docs) {
      batch.delete(doc.reference);
    }

    try {
      await batch.commit();
      debugPrint('[친구삭제] 성공: $currentUserId <-> $friendId');
    } catch (e) {
      debugPrint('[친구삭제] 실패(Batch Commit): $e');
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          throw Exception('친구 삭제 권한이 없습니다. 보안 규칙을 확인해 주세요.');
        } else if (e.code == 'not-found') {
          throw Exception('친구 삭제에 실패했습니다. 유저 정보가 존재하지 않습니다.');
        }
      }
      throw Exception('친구 삭제 중 오류가 발생했습니다: $e');
    }
  }
}
