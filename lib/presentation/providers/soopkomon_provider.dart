import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/usecases/check_hatching_usecase.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/data/repositories/soopkomon_repository_impl.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';
import 'package:soopkomong/data/datasources/remote_location_datasource.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

/// 1-1. 데이터 소스 프로바이더
final remoteLocationDataSourceProvider = Provider<RemoteLocationDataSource>((
  ref,
) {
  return RemoteLocationDataSourceImpl();
});

/// 1-3. 리포지토리 프로바이더
final soopkomonRepositoryProvider = Provider<SoopkomonRepository>((ref) {
  return SoopkomonRepositoryImpl(
    remoteDataSource: ref.watch(remoteLocationDataSourceProvider),
  );
});

/// 1-4. 유즈케이스 프로바이더
final checkHatchingUseCaseProvider = Provider<CheckHatchingUseCase>((ref) {
  return CheckHatchingUseCase(ref.watch(soopkomonRepositoryProvider));
});

/// 2. 전체 도감 템플릿 프로바이더 (Async)
final soopkomonTemplatesProvider = FutureProvider<List<SoopkomonTemplate>>((
  ref,
) async {
  final repository = ref.watch(soopkomonRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return repository.getSoopkomonTemplates(locale: locale);
});

/// 3. 모든 공원 위치 데이터 프로바이더 (Async)
final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final repository = ref.watch(soopkomonRepositoryProvider);
  final locale = ref.watch(localeProvider); // 언어 변경 감시
  return repository.getLocations(locale: locale);
});

/// 4. 선택된 지역 상태 관리
class SelectedRegion extends Notifier<Region> {
  @override
  Region build() => Region.all;

  void update(Region region) => state = region;
}

final selectedRegionProvider = NotifierProvider<SelectedRegion, Region>(
  SelectedRegion.new,
);

/// 5. 유저가 획득한 캐릭터 리스트 관리 (실시간 Firestore 연동)
final userSoopkomonProvider = StreamProvider<List<Soopkomon>>((ref) {
  final userAsync = ref.watch(userProvider);
  final repository = ref.watch(soopkomonRepositoryProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return repository.getUserSoopkomons(user.id).asyncMap((soopkomons) async {
        final templates = await ref.read(soopkomonTemplatesProvider.future);
        final templateMap = {for (var t in templates) t.templateId: t};

        return soopkomons.map((s) {
          final template = templateMap[s.templateId];
          if (template != null) {
            return s.copyWith(eggType: template.eggType);
          }
          return s;
        }).toList();
      });
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

/// 5-2. 특정 사용자가 획득한 캐릭터 리스트 관리 (매개변수 기반)
final friendSoopkomonProvider = StreamProvider.family<List<Soopkomon>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(soopkomonRepositoryProvider);

  return repository.getUserSoopkomons(userId).asyncMap((soopkomons) async {
    final templates = await ref.read(soopkomonTemplatesProvider.future);
    final templateMap = {for (var t in templates) t.templateId: t};

    return soopkomons.map((s) {
      final template = templateMap[s.templateId];
      if (template != null) {
        return s.copyWith(eggType: template.eggType);
      }
      return s;
    }).toList();
  });
});

/// 6. 필터링된 공원 리스트 (조합 프로바이더)
final filteredLocationsProvider = Provider<AsyncValue<List<Location>>>((ref) {
  final locationsAsync = ref.watch(locationsProvider);
  final selectedRegion = ref.watch(selectedRegionProvider);

  return locationsAsync.whenData((locations) {
    // 1. 고유 ID(contentId) 기준 중복 제거 (방어적 코드)
    final uniqueMap = <int, Location>{};
    for (var loc in locations) {
      uniqueMap[loc.id] = loc;
    }
    final deduplicated = uniqueMap.values.toList();

    // 2. 방문 이력 실시간 주입 (자물쇠 및 카운터 동기화용)
    final visitedIds = ref.watch(visitedLocationIdsProvider);
    final enhancedLocations = deduplicated
        .map((loc) => loc.copyWith(isVisited: visitedIds.contains(loc.id)))
        .toList();

    // 3. 지역 필터 적용
    if (selectedRegion == Region.all) return enhancedLocations;
    return enhancedLocations
        .where((loc) => loc.region == selectedRegion.label)
        .toList();
  });
});

/// 7. 필터링된 템플릿 리스트 (조합 프로바이더)
final filteredTemplatesProvider = Provider<AsyncValue<List<SoopkomonTemplate>>>(
  (ref) {
    final templatesAsync = ref.watch(soopkomonTemplatesProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return templatesAsync.whenData((templates) {
      // 1. 고유 ID(templateId) 기준 중복 제거 (방어적 코드)
      final uniqueMap = <String, SoopkomonTemplate>{};
      for (var t in templates) {
        uniqueMap[t.templateId] = t;
      }
      final deduplicated = uniqueMap.values.toList();

      // 2. 지역 필터 적용
      if (selectedRegion == Region.all) return deduplicated;
      return deduplicated.where((t) => t.region == selectedRegion).toList();
    });
  },
);

/// 8. 유저가 실제 방문한 모든 공원 ID 세트 (Single Source of Truth)
final visitedLocationIdsProvider = Provider<Set<int>>((ref) {
  final userSoopkomons = ref.watch(userSoopkomonProvider).value ?? [];
  final user = ref.watch(userProvider).value;

  // 1. 펫을 획득하여 방문한 적이 있는 ID들 추출
  final petVisitedIds = userSoopkomons
      .where((s) => s.discoveredSpotId != 'tutorial_start')
      .map((s) => int.tryParse(s.discoveredSpotId))
      .whereType<int>()
      .toSet();

  // 2. 유저 정보의 '잠금 해제 이력(unlockedParkIds)' 통합
  return {
    ...petVisitedIds,
    if (user != null) ...user.unlockedParkIds,
  };
});

/// 8-2. 유저가 실제 방문한 공원 리스트 (조합 프로바이더)
final userVisitedLocationsProvider = Provider<AsyncValue<List<Location>>>((
  ref,
) {
  final locationsAsync = ref.watch(locationsProvider);
  final visitedIds = ref.watch(visitedLocationIdsProvider);

  return locationsAsync.whenData((locations) {
    // 1. 고유 ID 기준 필터링 및 데이터 주입
    final visitedLocations = locations
        .where((loc) => visitedIds.contains(loc.id))
        .map((loc) => loc.copyWith(isVisited: true))
        .toList();

    // 2. 고유 ID(id) 기준 중복 제거
    final uniqueMap = <int, Location>{};
    for (var loc in visitedLocations) {
      uniqueMap[loc.id] = loc;
    }
    return uniqueMap.values.toList();
  });
});

/// 9. 중복 제거된 전체 공원 개수 (지역 필터 무시)
final totalLocationsCountProvider = Provider<AsyncValue<int>>((ref) {
  final locationsAsync = ref.watch(locationsProvider);
  return locationsAsync.whenData((locations) {
    final uniqueIds = locations.map((l) => l.id).toSet();
    return uniqueIds.length;
  });
});

/// 10. 중복 제거된 전체 템플릿 개수 (지역 필터 무시)
final totalTemplatesCountProvider = Provider<AsyncValue<int>>((ref) {
  final templatesAsync = ref.watch(soopkomonTemplatesProvider);
  return templatesAsync.whenData((templates) {
    final uniqueIds = templates.map((t) => t.templateId).toSet();
    return uniqueIds.length;
  });
});
/// 11. 현재 필터링된 지역 내 방문한 공원 개수
final currentFilteredLocationsCountProvider = Provider<int>((ref) {
  final filteredLocationsAsync = ref.watch(filteredLocationsProvider);
  return filteredLocationsAsync.maybeWhen(
    data: (locations) => locations.where((l) => l.isVisited).length,
    orElse: () => 0,
  );
});

/// 12. 현재 필터링된 지역 내 보유한 숲코몽 개수 (고유 종류 기준)
final currentFilteredSoopkomonsCountProvider = Provider<int>((ref) {
  final filteredTemplatesAsync = ref.watch(filteredTemplatesProvider);
  final userSoopkomonsAsync = ref.watch(userSoopkomonProvider);

  final templates = filteredTemplatesAsync.value ?? [];
  final userCharacters = userSoopkomonsAsync.value ?? [];

  if (templates.isEmpty) return 0;

  final ownedIds = userCharacters.map((c) => c.templateId).toSet();
  return templates.where((t) => ownedIds.contains(t.templateId)).length;
});
