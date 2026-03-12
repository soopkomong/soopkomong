import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

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
    final authRepository = ref.watch(authRepositoryProvider);
    final user = authRepository.currentUser;

    if (user == null) return [];

    // 1. 내 문서에서 친구 ID 리스트 가져오기
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .get();

    if (!userDoc.exists) return [];

    final data = userDoc.data();
    final List<String> friendIds = List<String>.from(data?['friends'] ?? []);

    if (friendIds.isEmpty) return [];

    // 2. 친구 ID들을 바탕으로 각 친구의 상세 정보 가져오기
    // Firestore 'whereIn' 쿼리는 최대 10개-30개 제한이 있으므로, 데이터가 많아지면 분할 처리가 필요할 수 있음
    // 여기서는 간단하게 개별 Fetch 또는 chunk 처리를 고려
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
  }

  // 친구 추가 기능
  Future<void> addFriend(String code) async {
    final authRepository = ref.read(authRepositoryProvider);
    final user = authRepository.currentUser;

    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      // 실제 Firestore 업데이트: 내 문서의 friends 배열에 친구 UID 추가
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'friends': FieldValue.arrayUnion([code]),
      });

      // 기존 리스트와 새 친구 합쳐서 상태 업데이트
      // 실시간 업데이트를 위해 invalidateSelf 호출
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
