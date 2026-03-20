import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/data/models/location_model.dart';
import 'package:soopkomong/data/models/soopkomon_template_model.dart';
import 'package:soopkomong/data/repositories/soopkomon_repository_impl.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';
import 'package:soopkomong/data/datasources/remote_location_datasource.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

/// 1-1. 데이터 소스 프로바이더
final remoteLocationDataSourceProvider = Provider<RemoteLocationDataSource>((ref) {
  return RemoteLocationDataSourceImpl();
});

/// 1-3. 리포지토리 프로바이더
final soopkomonRepositoryProvider = Provider<SoopkomonRepository>((ref) {
  return SoopkomonRepositoryImpl(
    remoteDataSource: ref.watch(remoteLocationDataSourceProvider),
  );
});

/// 2. 전체 도감 템플릿 프로바이더 (Async)
final soopkomonTemplatesProvider = FutureProvider<List<SoopkomonTemplate>>((
  ref,
) async {
  final jsonString = await rootBundle
      .loadString('assets/templates.json')
      .timeout(const Duration(seconds: 10));
  final List<dynamic> templatesJson = json.decode(jsonString) as List<dynamic>;
  return templatesJson
      .map((e) => SoopkomonTemplateModel.fromJson(e as Map<String, dynamic>).toEntity())
      .toList();
});

/// 3. 모든 공원 위치 데이터 프로바이더 (Async)
final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final jsonString = await rootBundle
      .loadString('assets/locations.json')
      .timeout(const Duration(seconds: 10));
  final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final List<dynamic> locationsData = jsonData['locations'] ?? [];
  return locationsData
      .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
      .toList();
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
      return repository.getUserSoopkomons(user.id);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
});

// 기존 Notifier 기반의 add/update 로직은 이제 Firestore에 직접 쓰고 스트림으로 반영받는 식으로 변경되어야 하므로 제거하거나 별도 UI 핸들러로 이동
// (현재 도감 뷰 기능에 집중하기 위해 StreamProvider로 교체)

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

    // 2. 지역 필터 적용
    if (selectedRegion == Region.all) return deduplicated;
    return deduplicated
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
