import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/user_provider.dart';

class FriendsViewModel extends AsyncNotifier<List<FriendModel>> {
  @override
  Future<List<FriendModel>> build() async {
    final userDocAsync = ref.watch(userDocumentProvider);
    
    return userDocAsync.when(
      data: (userDoc) async {
        if (userDoc == null || !userDoc.exists) return [];

        final data = userDoc.data() as Map<String, dynamic>?;
        final List<String> friendIds = List<String>.from(data?['friends'] ?? [])
            .where((id) => id.trim().isNotEmpty)
            .toList();
        final Map<String, dynamic> friendships = data?['friendships'] ?? {};

        if (friendIds.isEmpty) return [];

        final List<FriendModel> friends = [];
        
        for (var i = 0; i < friendIds.length; i += 30) {
          final chunk = friendIds.sublist(i, i + 30 > friendIds.length ? friendIds.length : i + 30);
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          
          friends.addAll(querySnapshot.docs.map((doc) {
            final friendshipTimestamp = friendships[doc.id];
            DateTime? friendedAt;
            if (friendshipTimestamp is Timestamp) {
              friendedAt = friendshipTimestamp.toDate();
            }
            return FriendModel.fromFirestore(doc, friendedAtOverride: friendedAt);
          }));
        }
        
        // 추가된 순서대로 정렬 (friendIds 리스트의 인덱스 기준)
        friends.sort((a, b) => friendIds.indexOf(a.id).compareTo(friendIds.indexOf(b.id)));
        
        return friends;
      },
      loading: () => state.value ?? [],
      error: (e, st) => throw e,
    );
  }

  Future<FriendModel> getFriendModelByUserId(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('유저를 찾을 수 없습니다.');
    return FriendModel.fromFirestore(doc);
  }

  // 친구 요청 보내기 기능
  Future<void> sendFriendRequest(String targetInput) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    String targetId = targetInput.trim();

    try {
      // 1. 입력값이 user_code인지 확인하기 위해 Firestore 쿼리
      final userCodeQuery = await FirebaseFirestore.instance
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

      // 이미 친구인지 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .get();
      final List<String> friends = List<String>.from(userDoc.data()?['friends'] ?? []);
      if (friends.contains(targetId)) {
        throw Exception('이미 친구입니다.');
      }

      // 이미 보내진 요청이 있는지 확인
      final existingRequest = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', isEqualTo: currentUser.id)
          .where('receiverId', isEqualTo: targetId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('이미 친구 요청을 보냈습니다.');
      }

      // 상대방 존재 여부 확인 (UID로 검색)
      final targetDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetId)
          .get();
      if (!targetDoc.exists) {
        throw Exception('해당 코드 또는 ID의 유저를 찾을 수 없습니다.');
      }

      // 내 캐릭터 템플릿 ID 가져오기
      final myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .get();
      final myTemplateId = myDoc.data()?['templateId'] ?? '007';

      // 친구 요청 문서 생성
      final request = FriendRequest(
        id: '',
        senderId: currentUser.id,
        senderName: currentUser.displayName ?? '익명',
        senderTemplateId: myTemplateId,
        receiverId: targetId,
        status: FriendRequestStatus.pending,
        notified: false,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('friend_requests')
          .add(request.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // 친구 요청 수락
  Future<void> acceptFriendRequest(FriendRequest request) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;

    print('-----------------------------------------');
    print('🚀 [DEBUG] 1. 수락 프로세스 시작');
    print('📍 [DEBUG] 요청 문서 ID: ${request.id}');
    print('📍 [DEBUG] 보낸 사람 ID(Sender): ${request.senderId}');
    print('📍 [DEBUG] 받는 사람 ID(Me): ${currentUser?.id}');

    if (currentUser == null) {
      print('❌ [DEBUG] 에러: 로그인된 사용자가 없습니다.');
      return;
    }

    // 본인에게 온 요청인지 확인 (ID 불일치 방지)
    if (request.receiverId != currentUser.id) {
      print('❌ [DEBUG] 에러: 본인에게 온 요청이 아닙니다.');
      throw Exception('본인에게 온 친구 요청만 수락할 수 있습니다.');
    }

    if (request.id.isEmpty) {
      print('❌ [DEBUG] 에러: request.id가 비어있습니다. Firestore 문서를 수정할 수 없습니다.');
      throw Exception('요청 ID가 유효하지 않습니다.');
    }

    try {
      final batch = FirebaseFirestore.instance.batch();

      print('🛠️ [DEBUG] 2. Batch 작업 준비 중...');

      // 1. 요청 상태 변경
      final requestRef = FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(request.id);
      batch.update(requestRef, {'status': 'accepted'});

      // 2. 내 친구 목록 및 날짜 추가
      final myRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id);
      batch.update(myRef, {
        'friends': FieldValue.arrayUnion([request.senderId]),
        'friendships.${request.senderId}': FieldValue.serverTimestamp(),
      });
      print('📍 friendships.${request.senderId} 에 서버 시간 추가');

      // 3. 상대방 친구 목록 및 날짜 추가
      final senderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(request.senderId);
      batch.update(senderRef, {
        'friends': FieldValue.arrayUnion([currentUser.id]),
        'friendships.${currentUser.id}': FieldValue.serverTimestamp(),
      });
      print('📍 friendships.${currentUser.id} 에 서버 시간 추가 (상대방 측)');

      print('⚙️ [DEBUG] 3. Batch Commit 시도...');

      await batch.commit();

      print('✅ [DEBUG] 4. 수락 완료! Firestore 데이터 변경 성공');
      print('-----------------------------------------');
      
    } catch (e, stack) {
      print('❌ [DEBUG] 5. 수락 처리 중 치명적 에러 발생!');
      print('❌ [DEBUG] 에러 내용: $e');
      print('❌ [DEBUG] 스택 트레이스: $stack');
      print('-----------------------------------------');
      rethrow;
    }
  }

  // 친구 요청 거절
  Future<void> declineFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'declined'});
    } catch (e) {
      rethrow;
    }
  }

  // 모든 대기 중인 친구 요청 알림 확인 처리
  Future<void> markAllPendingRequestsAsNotified() async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: currentUser.id)
          .where('status', isEqualTo: 'pending')
          .where('notified', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'notified': true});
      }
      await batch.commit();
    } catch (e) {
      print('❌ [DEBUG] markAllPendingRequestsAsNotified 에러: $e');
    }
  }

  // 친구 요청 알림 확인 처리 (팝업 노출 완료 표시)
  Future<void> markNotified(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'notified': true});
    } catch (e) {
      print('❌ [DEBUG] markNotified 에러: $e');
    }
  }

  // 알림(친구 요청) 삭제
  Future<void> deleteNotification(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      print('❌ [DEBUG] 알림 삭제 중 에러 발생: $e');
      rethrow;
    }
  }

  Future<void> addFriend(String code) async {
    await sendFriendRequest(code);
  }

  // 친구 삭제
  Future<void> removeFriend(String friendId) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. 내 친구 목록 및 날짜 데이터 삭제
      final myRef = FirebaseFirestore.instance.collection('users').doc(currentUser.id);
      batch.update(myRef, {
        'friends': FieldValue.arrayRemove([friendId]),
        'friendships.$friendId': FieldValue.delete(),
      });

      // 2. 상대방 친구 목록 및 날짜 데이터 삭제
      final friendRef = FirebaseFirestore.instance.collection('users').doc(friendId);
      batch.update(friendRef, {
        'friends': FieldValue.arrayRemove([currentUser.id]),
        'friendships.${currentUser.id}': FieldValue.delete(),
      });

      // 3. 관련 친구 요청 문서 삭제 (재신청이 가능하도록 정리)
      final requestsQuery = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('senderId', whereIn: [currentUser.id, friendId])
          .get();

      for (var doc in requestsQuery.docs) {
        final data = doc.data();
        final senderId = data['senderId'];
        final receiverId = data['receiverId'];

        // 내 ID와 상대방 ID가 서로 교차되어 있는지 확인 (A->B or B->A)
        if ((senderId == currentUser.id && receiverId == friendId) ||
            (senderId == friendId && receiverId == currentUser.id)) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();

      // UI 즉시 업데이트를 위해 리프레시
      ref.invalidateSelf();
    } catch (e) {
      print('❌ [DEBUG] 친구 삭제 중 에러 발생: $e');
      rethrow;
    }
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
