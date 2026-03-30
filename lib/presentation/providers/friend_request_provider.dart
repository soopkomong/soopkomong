import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_provider.dart';

/// 친구 신청 목록 리스트를 관리하는 스트림 프로바이더입니다.
///
/// [Presentation Layer] - Provider
final friendRequestProvider = StreamProvider<List<FriendRequest>>((ref) {
  final userAsync = ref.watch(userProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final friendRepo = ref.read(friendRepositoryProvider);
      return friendRepo.getPendingFriendRequests(user.id);
    },
    // 인증 정보 로딩 중에는 빈 스트림을 반환하여 로딩 상태를 유지합니다.
    // UI(HomePage 등)에서는 .value ?? [] 를 사용하여 무한 로딩을 방지할 수 있습니다.
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
});
