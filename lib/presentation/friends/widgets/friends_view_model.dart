import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/user_provider.dart';

class FriendModel {
  final String id; // 친구의 고유 id
  final String name; // 친구 이름
  final String characterTemplateId;
  final int leafProgress; // 친구의 현재 레벨
  final int leafMax; // 최대 레벨
  final int pawProgress; // 얻은 캐릭터
  final int pawMax; // 최대 캐릭터

  FriendModel({
    required this.id,
    required this.name,
    required this.characterTemplateId,
    required this.leafProgress,
    required this.leafMax,
    required this.pawProgress,
    required this.pawMax,
  });

  factory FriendModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FriendModel(
      id: doc.id,
      name: data['displayName'] ?? '이름 없음',
      characterTemplateId: data['templateId'] ?? '001',
      leafProgress: data['leafProgress'] ?? 0,
      leafMax: data['leafMax'] ?? 50,
      pawProgress: data['pawProgress'] ?? 0,
      pawMax: data['pawMax'] ?? 30,
    );
  }
}

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

        if (friendIds.isEmpty) return [];

        final List<FriendModel> friends = [];
        for (var friendId in friendIds) {
          final friendDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .get();
          if (friendDoc.exists) {
            friends.add(FriendModel.fromFirestore(friendDoc));
          }
        }
        return friends;
      },
      loading: () => state.value ?? [],
      error: (e, st) => throw e,
    );
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

      // 친구 요청 문서 생성
      final request = FriendRequest(
        id: '',
        senderId: currentUser.id,
        senderName: currentUser.displayName ?? '익명',
        receiverId: targetId,
        status: FriendRequestStatus.pending,
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
    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. 요청 상태 변경
      final requestRef = FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(request.id);
      batch.update(requestRef, {'status': 'accepted'});

      // 2. 내 친구 목록에 추가
      final myRef = FirebaseFirestore.instance
          .collection('users')
          .doc(request.receiverId);
      batch.update(myRef, {
        'friends': FieldValue.arrayUnion([request.senderId])
      });

      // 3. 상대방 친구 목록에 추가
      final senderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(request.senderId);
      batch.update(senderRef, {
        'friends': FieldValue.arrayUnion([request.receiverId])
      });

      await batch.commit();
      ref.invalidateSelf();
    } catch (e) {
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

  // (기존 addFriend 메서드는 유지하되 내부 로직은 sendFriendRequest 호출로 가이드하거나 삭제 가능)
  // 여기서는 호환성을 위해 유지하거나 sendFriendRequest로 대체 안내
  Future<void> addFriend(String code) async {
    await sendFriendRequest(code);
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
