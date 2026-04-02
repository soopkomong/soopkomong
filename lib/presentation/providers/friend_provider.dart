import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/data/repositories/friend_repository_impl.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/repositories/friend_repository.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepositoryImpl(FirebaseFirestore.instance);
});

final friendUserProvider = StreamProvider.family<AppUser, String>((ref, userId) {
  final repository = ref.watch(friendRepositoryProvider);
  return repository.getUserStream(userId);
});

/// 친구가 방문한 공원 ID 세트
final friendVisitedLocationIdsProvider = Provider.family<Set<int>, String>((ref, userId) {
  final user = ref.watch(friendUserProvider(userId)).value;
  if (user == null) return {};
  
  // 엔티티의 비즈니스 로직 활용
  return user.getVisitedParkIds();
});

/// 친구가 방문한 공원 상세 리스트
final friendVisitedLocationsProvider = Provider.family<AsyncValue<List<Location>>, String>((ref, userId) {
  final locationsAsync = ref.watch(locationsProvider);
  final visitedIds = ref.watch(friendVisitedLocationIdsProvider(userId));

  return locationsAsync.whenData((locations) {
    final visitedLocations = locations
        .where((loc) => visitedIds.contains(loc.id))
        .map((loc) => loc.copyWith(isVisited: true))
        .toList();

    // 중복 제거
    final uniqueMap = <int, Location>{};
    for (var loc in visitedLocations) {
      uniqueMap[loc.id] = loc;
    }
    return uniqueMap.values.toList();
  });
});

/// 친구 프로필 상단 배지용 데이터 (방문 수, 획득 수)
final friendVisitCountProvider = Provider.family<AsyncValue<({int visitedCount, int collectedCount})>, String>((ref, userId) {
  final visitedIds = ref.watch(friendVisitedLocationIdsProvider(userId));
  final charactersAsync = ref.watch(friendSoopkomonProvider(userId));

  return charactersAsync.whenData((characters) {
    return (
      visitedCount: visitedIds.length,
      collectedCount: characters.length,
    );
  });
});
