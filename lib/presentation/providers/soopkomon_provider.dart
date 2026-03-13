import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/data/repositories/soopkomon_repository_impl.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';

/// 1. 리포지토리 프로바이더
final soopkomonRepositoryProvider = Provider<SoopkomonRepository>((ref) {
  return SoopkomonRepositoryImpl();
});

/// 2. 전체 도감 템플릿 프로바이더 (Async)
final soopkomonTemplatesProvider = FutureProvider<List<SoopkomonTemplate>>((
  ref,
) async {
  final repository = ref.watch(soopkomonRepositoryProvider);
  return repository.getSoopkomonTemplates();
});

/// 3. 모든 공원 위치 데이터 프로바이더 (Async)
final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final repository = ref.watch(soopkomonRepositoryProvider);
  return repository.getLocations();
});

/// 4. 선택된 지역 상태 관리
class SelectedRegion extends Notifier<Region> {
  @override
  Region build() => Region.capital;

  void update(Region region) => state = region;
}

final selectedRegionProvider = NotifierProvider<SelectedRegion, Region>(
  SelectedRegion.new,
);

/// 5. 유저가 획득한 캐릭터 리스트 관리
// TODO: 실제 값 연결해야함
class UserSoopkomon extends Notifier<List<Soopkomon>> {
  @override
  List<Soopkomon> build() {
    return [
      Soopkomon(
        instanceId: 'test-1',
        templateId: '007',
        name: '다람이',
        discoveredSpotId: '12345',
        discoveredSpotName: '서울숲',
        discoveredAddr: '서울특별시 성동구',
        discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
        stepsAtDiscovery: 10000,
        currentTotalSteps: 15000,
      ),
      Soopkomon(
        instanceId: 'test-2',
        templateId: '008',
        name: '토끼',
        discoveredSpotId: '54321',
        discoveredSpotName: '남산공원',
        discoveredAddr: '서울특별시 중구',
        discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
        stepsAtDiscovery: 20000,
        currentTotalSteps: 22000,
      ),
    ];
  }

  void add(Soopkomon character) => state = [...state, character];
}

final userSoopkomonProvider = NotifierProvider<UserSoopkomon, List<Soopkomon>>(
  UserSoopkomon.new,
);

/// 6. 필터링된 공원 리스트 (조합 프로바이더)
final filteredLocationsProvider = Provider<AsyncValue<List<Location>>>((ref) {
  final locationsAsync = ref.watch(locationsProvider);
  final selectedRegion = ref.watch(selectedRegionProvider);

  return locationsAsync.whenData((locations) {
    return locations
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
      return templates.where((t) => t.region == selectedRegion).toList();
    });
  },
);
