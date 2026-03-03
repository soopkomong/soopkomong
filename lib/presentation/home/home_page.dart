import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:soopkomong/core/utils/map_helper.dart';
import 'package:soopkomong/core/utils/turf_helper.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';
import 'package:soopkomong/core/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soopkomong/domain/entities/pet_location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:soopkomong/core/router/app_route.dart';

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
  bool _markersAdded = false;
  final Map<String, int> _markerIndexMap = {};
  Timer? _themeTimer;
  StreamSubscription<geo.Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    // 첫 프레임 렌더링 후 비동기로 데이터 로드 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadData();
    });

    // initState에서도 권한을 먼저 요청하고, 초기 카메라 위치를 잡기 위해 실행
    _moveToCurrentLocation();

    // 1분(60초)마다 현재 시간 확인하여 테마 갱신
    _themeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mapboxMap != null) {
        _applyDayNightTheme(mapboxMap!);
      }
    });
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
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

    // 공원 주변 500m 반경 폴리곤 생성
    polygonAnnotationManager = await mapboxMap!.annotations
        .createPolygonAnnotationManager();
    List<PolygonAnnotationOptions> polygonOptions = [];

    for (var loc in locations) {
      final center = Position(loc.lng, loc.lat);
      // turf_helper를 사용하여 500미터 반경의 원 형태 폴리곤 생성
      final circleCoordinates = createCircleCoordinates(center, 500.0);

      polygonOptions.add(
        PolygonAnnotationOptions(
          geometry: Polygon(coordinates: [circleCoordinates]),
          fillColor: Colors.blue.withValues(alpha: 0.2).toARGB32(),
          fillOutlineColor: Colors.blue.toARGB32(),
        ),
      );
    }
    await polygonAnnotationManager?.createMulti(polygonOptions);
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // UI 컨트롤 숨기기 (나침반, 로고, 속성 ⓘ 아이콘, 스케일바)
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    await mapboxMap.attribution.updateSettings(
      AttributionSettings(enabled: false),
    );
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // 내 위치 파란색 점(Puck) 표시 활성화
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(enabled: true, puckBearingEnabled: true),
    );

    // 카메라 줌인 한계(minZoom) 설정 - 가장 멀리보는 최대 반경 14.5
    await mapboxMap.setBounds(CameraBoundsOptions(minZoom: 14.5));

    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    // 화면 이동(스크롤) 제스처 비활성화하여 내 위치 중심 고정
    // 핀치(확대/축소) 및 회전 시에도 화면 중앙 좌표를 축으로 사용하여 이탈 방지
    await mapboxMap.gestures.updateSettings(
      GesturesSettings(
        scrollEnabled: false,
        pinchPanEnabled: false,
        focalPoint: ScreenCoordinate(x: size.width / 2.0, y: size.height / 2.0),
      ),
    );

    // ViewModel의 현재 상태를 가져와 마커 추가 시도
    final state = ref.read(homeViewModelProvider);
    if (!state.isLoading && state.locations.isNotEmpty) {
      _addMarkers(state.locations);
    }

    // 초기 테마(낮/밤) 적용
    await _applyDayNightTheme(mapboxMap);

    // 맵 생성 후에도 다시 한번 내 위치로 카메라 이동을 보장
    await _moveToCurrentLocation();
  }

  Future<void> _applyDayNightTheme(MapboxMap mapbox) async {
    final int currentHour = DateTime.now().hour;

    // 6시부터 17시 59분까지는 day, 그 외는 night
    final String timePreset = (currentHour >= 6 && currentHour < 18)
        ? "day"
        : "night";

    // Mapbox Standard 스타일에 timePreset 적용
    try {
      await mapbox.style.setStyleImportConfigProperty(
        "basemap",
        "lightPreset",
        timePreset,
      );
    } catch (e) {
      debugPrint("테마 갱신 에러: $e");
    }
  }

  Future<void> _moveToCurrentLocation() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) return;
    }

    if (permission == geo.LocationPermission.deniedForever) return;

    final position = await geo.Geolocator.getCurrentPosition();

    // 맵이 아직 렌더링되지 않았을 수도 있으므로 mapboxMap 객체가 있는지 확인
    if (mapboxMap != null) {
      mapboxMap?.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 16.5,
        ),
      );
      // 한번 셋팅 후, 실시간으로 위치가 바뀔 때마다 카메라를 내 위치로 이동시키는 리스너 등록
      _positionStreamSubscription ??=
          geo.Geolocator.getPositionStream(
            locationSettings: const geo.LocationSettings(
              accuracy: geo.LocationAccuracy.high,
              distanceFilter: 5, // 5미터 이동할 때마다 업데이트
            ),
          ).listen((geo.Position newPosition) {
            if (mapboxMap != null) {
              mapboxMap?.setCamera(
                CameraOptions(
                  center: Point(
                    coordinates: Position(
                      newPosition.longitude,
                      newPosition.latitude,
                    ),
                  ),
                  // 줌은 유지하거나 필요시 16.5 등 고정 가능. 일단 이동만 시킴
                ),
              );
            }
          });
    } else {
      // 만약 아직 mapboxMap이 생성되기 전이라면 build 메서드의 initialCameraOptions에 영향을 줄 수 있도록
      // 상태로 저장해두는 방법도 있지만, onMapCreated에서 다시 호출하므로 여기서는 무시해도 됩니다.
      debugPrint("mapboxMap이 아직 초기화되지 않았습니다. 맵 생성 후 이동합니다.");
    }
  }

  void _showLocationDetails(int index, List<PetLocation> locations) {
    if (index < 0 || index >= locations.length) return;

    final loc = locations[index];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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

    // 다른 탭이나 페이지에서 복귀 시 줌 초기화 이벤트를 수신합니다.
    ref.listen(mapZoomResetProvider, (_, _) {
      _moveToCurrentLocation();
    });

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
            onPressed: () async {
              await context.pushNamed(AppRoute.mypage.name);
              // MyPage에서 뒤로가기로 돌아왔을 때 줌 레벨 복구를 위해 이벤트 트리거
              ref.read(mapZoomResetProvider.notifier).triggerReset();
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
            // _applyDayNightTheme가 정상적으로 먹게 하려면 Mapbox Standard 스타일을 베이스로 사용합니다
            styleUri: dotenv.env['MAPBOX_STYLE_URI'] ?? MapboxStyles.STANDARD,
            onMapCreated: _onMapCreated,
            // 줌/내비게이션 시에도 완벽하게 내 위치가 가운데 고정되도록 Viewport 사용
            viewport: FollowPuckViewportState(zoom: 16.5, pitch: 0.0),
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(127.7669, 35.9078)),
              zoom: 16.5,
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
