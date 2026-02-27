import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:soopkomong/core/router/app_route.dart';
import '../../core/utils/map_helper.dart';
import '../../core/utils/turf_helper.dart';
import 'home_viewmodel.dart';
import '../../domain/entities/pet_location.dart';

/// [Presentation Layer] - View
/// 사용자에게 직접 보여지는 화면을 구성하는 위젯입니다.
/// flutter_riverpod의 [ConsumerStatefulWidget]을 사용하여 ViewModel의 상태를 구독하며,
/// 비즈니스 로직과 상태 관리는 [HomeViewModel]에 모두 위임하고 렌더링에만 집중합니다.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;
  bool _isMarkerVisible = false;
  bool _markersAdded = false;
  final Map<String, int> _markerIndexMap = {};

  @override
  void initState() {
    super.initState();
    // 첫 프레임 렌더링 후 비동기로 데이터 로드 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadData();
    });
  }

  Future<void> _addMarkers(List<PetLocation> locations) async {
    if (mapboxMap == null || locations.isEmpty || _markersAdded) return;
    _markersAdded = true;

    // annotation manager 생성
    pointAnnotationManager = await mapboxMap!.annotations
        .createPointAnnotationManager();

    List<PointAnnotationOptions> options = [];

    // 커스텀 마커 생성 및 등록 (타입별로 다른 색상의 마커 이미지 등록)
    final Set<String> uniqueTypes = locations.map((loc) => loc.petType).toSet();
    final Map<String, String> typeToImageId = {};

    for (var type in uniqueTypes) {
      final String imageId =
          'icon_marker_${type}_${DateTime.now().millisecondsSinceEpoch}';
      final Uint8List markerBytes = await createIconMarkerBitmap(
        Icons.location_pin,
        _getPetTypeColor(type),
        size: 150.0,
      );

      try {
        await mapboxMap!.style.addStyleImage(
          imageId,
          3.0,
          MbxImage(width: 150, height: 150, data: markerBytes),
          false,
          [],
          [],
          null,
        );
      } catch (_) {
        debugPrint("이미지 등록 실패 (무시됨)");
      }
      typeToImageId[type] = imageId;
    }

    for (var loc in locations) {
      // Point 구조: Point(coordinates: Position(lng, lat))
      final point = Point(coordinates: Position(loc.lng, loc.lat));

      options.add(
        PointAnnotationOptions(
          geometry: point,
          iconImage: typeToImageId[loc.petType],
          iconSize: 1.0,
        ),
      );
    }

    final annotations =
        await pointAnnotationManager?.createMulti(options) ?? [];

    // 초기 마커 투명도 적용
    await pointAnnotationManager?.setIconOpacity(_isMarkerVisible ? 1.0 : 0.0);

    // 마커 ID와 인덱스 매핑 저장
    _markerIndexMap.clear();
    for (int i = 0; i < annotations.length; i++) {
      final id = annotations[i]?.id;
      if (id != null) {
        _markerIndexMap[id] = i;
      }
    }

    // 마커 탭 이벤트 리스너 등록
    pointAnnotationManager?.tapEvents(
      onTap: (PointAnnotation annotation) {
        final index = _markerIndexMap[annotation.id];
        if (index != null) {
          _showLocationDetails(index, locations);
        }
      },
    );

    // 50m 반경 폴리곤(경계선) 그리기 추가
    polygonAnnotationManager = await mapboxMap!.annotations
        .createPolygonAnnotationManager();
    List<PolygonAnnotationOptions> polygonOptions = [];

    for (var loc in locations) {
      final center = Position(loc.lng, loc.lat);
      // turf_helper를 사용하여 50미터 반경의 원 형태 폴리곤 생성
      final circleCoordinates = createCircleCoordinates(center, 50.0);

      polygonOptions.add(
        PolygonAnnotationOptions(
          geometry: Polygon(coordinates: [circleCoordinates]),
          fillColor: Colors.blue.withValues(alpha: 0.2).toARGB32(),
          fillOutlineColor: Colors.blue.toARGB32(),
        ),
      );
    }
    await polygonAnnotationManager?.createMulti(polygonOptions);
    // 초기 폴리곤 면 투명도 적용
    await polygonAnnotationManager?.setFillOpacity(
      _isMarkerVisible ? 1.0 : 0.0,
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    // Mapbox의 기본 스타일 라벨(텍스트) 모두 숨김 처리
    try {
      final style = mapboxMap.style;
      final layers = await style.getStyleLayers();
      // layer id에 label, poi, place 등이 포함되어 있는 레이어 숨김 처리
      for (var layer in layers) {
        if (layer == null) continue;
        final id = layer.id.toLowerCase();
        if (id.contains('label') ||
            id.contains('poi') ||
            id.contains('place')) {
          await style.setStyleLayerProperty(layer.id, "visibility", "none");
        }
      }
    } catch (e) {
      debugPrint("레이어 필터링 에러: $e");
    }

    // ViewModel의 현재 상태를 가져와 마커 추가 시도
    final state = ref.read(homeViewModelProvider);
    if (!state.isLoading && state.locations.isNotEmpty) {
      _addMarkers(state.locations);
    }
  }

  void _showLocationDetails(int index, List<PetLocation> locations) {
    if (index < 0 || index >= locations.length) return;

    final loc = locations[index];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.region,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getPetTypeColor(loc.petType).withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets,
                      color: _getPetTypeColor(loc.petType),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.petName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPetTypeColor(loc.petType),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                loc.petType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Color _getPetTypeColor(String type) {
    switch (type) {
      case '물':
        return Colors.blue;
      case '땅':
        return Colors.brown;
      case '풀':
        return Colors.green;
      case '비행':
        return Colors.lightBlueAccent;
      case '신비':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    // 데이터가 로드되면 마커 추가 (mapbox 맵 객체가 있을 때만)
    if (!state.isLoading && state.locations.isNotEmpty && mapboxMap != null) {
      _addMarkers(state.locations);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.pushNamed(AppRoute.mypage.name);
            },
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            onCameraChangeListener: (CameraChangedEventData event) async {
              if (mapboxMap == null) return;
              final cameraState = await mapboxMap!.getCameraState();
              final double zoom = cameraState.zoom;
              // 줌 레벨 8.5 이상(약 20km 축척 이하)일 때 표시
              final bool shouldShow = zoom >= 8.5;

              if (shouldShow != _isMarkerVisible) {
                // UI를 갱신할 필요 없이 Mapbox의 opacity만 제어하여 퍼포먼스 향상
                _isMarkerVisible = shouldShow;
                pointAnnotationManager?.setIconOpacity(shouldShow ? 1.0 : 0.0);
                polygonAnnotationManager?.setFillOpacity(
                  shouldShow ? 1.0 : 0.0,
                );
              }
            },
            cameraOptions: CameraOptions(
              // 요구사항에 맞춰 모든 지도 초기 값은 대한민국 중심, 줌레벨 6.0, 피쳐 0, 방향 0
              center: Point(coordinates: Position(127.7669, 35.9078)),
              zoom: 6.0,
              pitch: 0.0, // 3D 건물이 눕지 않게 완벽한 2D 평면
              bearing: 0.0, // 북쪽 고정
            ),
          ),
          if (state.isLoading) const Center(child: CircularProgressIndicator()),
          if (state.errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withValues(alpha: 0.8),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
