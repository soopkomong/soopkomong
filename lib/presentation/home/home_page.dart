import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/core/utils/map_helper.dart';
import 'package:soopkomong/core/utils/turf_helper.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:soopkomong/presentation/home/home_viewmodel.dart';
import 'package:soopkomong/core/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/home/widgets/step_count_card.dart';
import 'package:soopkomong/domain/entities/soopkomon_enums.dart';
import 'package:soopkomong/presentation/core/extensions/egg_type_extension.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/park_detail_sheet.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/home/widgets/app_bar_icon.dart';
import 'package:soopkomong/presentation/home/widgets/pet_acquired_dialog.dart';
import 'package:soopkomong/presentation/home/widgets/pet_hatched_dialog.dart';
import 'package:soopkomong/presentation/home/widgets/park_unlocked_dialog.dart';
import 'package:soopkomong/presentation/home/widgets/home_hamburger_menu.dart';

/// [Presentation Layer] - View
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final double _defaultZoomLevel = 16.5;

  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;
  Timer? _themeTimer;
  final Map<String, int> _markerIndexMap = {};
  bool _isAddingMarkers = false;
  bool _isMapReady = false; // 지도 플랫폼 채널 준비 상태 플래그
  bool _hasMovedToInitialLocation = false; // 최초 위치 이동 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadData();
      ref.read(homeViewModelProvider.notifier).startTracking();
    });

    _themeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mapboxMap != null) {
        _applyDayNightTheme(mapboxMap!);
      }
    });
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    super.dispose();
  }

  Future<void> _addMarkers(
    List<Location> locations,
    List<SoopkomonTemplate> templates,
  ) async {
    if (mapboxMap == null ||
        !_isMapReady ||
        locations.isEmpty ||
        _isAddingMarkers) {
      return;
    }
    _isAddingMarkers = true;

    try {
      // 매니저가 없거나 이전 지도의 매니저인 경우 새로 생성합니다.
      // deleteAll 실패 시 매니저를 재생성하여 복구합니다.
      if (polygonAnnotationManager == null) {
        polygonAnnotationManager = await mapboxMap!.annotations
            .createPolygonAnnotationManager();
      } else {
        try {
          await polygonAnnotationManager?.deleteAll();
        } catch (_) {
          polygonAnnotationManager = await mapboxMap!.annotations
              .createPolygonAnnotationManager();
        }
      }

      if (pointAnnotationManager == null) {
        pointAnnotationManager = await mapboxMap!.annotations
            .createPointAnnotationManager();
      } else {
        try {
          await pointAnnotationManager?.deleteAll();
        } catch (_) {
          pointAnnotationManager = await mapboxMap!.annotations
              .createPointAnnotationManager();
        }
      }

      pointAnnotationManager?.tapEvents(
        onTap: (PointAnnotation annotation) {
          final index = _markerIndexMap[annotation.id];
          if (index != null) {
            _showLocationDetails(index);
          }
        },
      );

      List<PointAnnotationOptions> options = [];

      SoopkomonEggType getEggType(Location loc) {
        if (loc.petIds.isEmpty) return SoopkomonEggType.psychic;
        try {
          return templates
              .firstWhere((t) => t.templateId == loc.petIds.first)
              .eggType;
        } catch (_) {
          return SoopkomonEggType.psychic;
        }
      }

      final Set<SoopkomonEggType> uniqueTypes = locations
          .map((loc) => getEggType(loc))
          .toSet();
      final Map<SoopkomonEggType, String> typeToImageId = {};

      for (var type in uniqueTypes) {
        final String imageId =
            'icon_marker_${type.name}_${DateTime.now().millisecondsSinceEpoch}';
        final Uint8List markerBytes = await createSvgMarkerBitmap(
          Assets.pin,
          type.color,
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
        } catch (_) {}
        typeToImageId[type] = imageId;
      }

      for (var loc in locations) {
        final point = Point(coordinates: Position(loc.lng, loc.lat));
        final eggType = getEggType(loc);

        options.add(
          PointAnnotationOptions(
            geometry: point,
            iconImage: typeToImageId[eggType],
            iconSize: 1.0,
          ),
        );
      }

      List<PolygonAnnotationOptions> polygonOptions = [];

      for (var loc in locations) {
        final center = Position(loc.lng, loc.lat);
        final circleCoordinates = createCircleCoordinates(center, loc.radius);

        final bool isNight = _isNight();
        final Color polygonColor = isNight
            ? AppColors.error
            : AppColors.lightBlue;
        final double fillOpacity = isNight ? 0.1 : 0.1;

        polygonOptions.add(
          PolygonAnnotationOptions(
            geometry: Polygon(coordinates: [circleCoordinates]),
            fillColor: polygonColor.withValues(alpha: fillOpacity).toARGB32(),
            fillOutlineColor: polygonColor.toARGB32(),
          ),
        );
      }

      // Ensure polygons are added before points so points are on top
      await polygonAnnotationManager?.createMulti(polygonOptions);
      final annotations =
          await pointAnnotationManager?.createMulti(options) ?? [];

      _markerIndexMap.clear();
      for (int i = 0; i < annotations.length; i++) {
        final id = annotations[i]?.id;
        if (id != null) {
          _markerIndexMap[id] = i;
        }
      }
    } catch (e) {
      // 지도 채널이 아직 준비되지 않았거나 파괴된 경우 조용히 실패합니다.
      debugPrint("마커 추가 중 오류 발생: $e");
      // 매니저 참조를 초기화하여 다음 시도 시 재생성되도록 합니다.
      polygonAnnotationManager = null;
      pointAnnotationManager = null;
    } finally {
      _isAddingMarkers = false;
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // 지도가 새로 생성되면 이전 매니저 참조를 초기화하여
    // 파괴된 플랫폼 채널 참조를 방지합니다.
    pointAnnotationManager = null;
    polygonAnnotationManager = null;
    _markerIndexMap.clear();
    _isMapReady = false;
    _hasMovedToInitialLocation = false;

    // 지도가 생성된 시점에 이미 위치를 받아왔다면 이를 '초기 이동 완료' 상태로 간주
    // (이미 cameraOptions.center에서 해당 위치를 사용하기 때문)
    final currentState = ref.read(homeViewModelProvider);
    if (currentState.currentPosition != null) {
      _hasMovedToInitialLocation = true;
      debugPrint('[디버그] 지도 생성 시점에 이미 위치가 있어 초기 이동 완료로 설정함');
    }

    Future.microtask(() async {
      if (!mounted) return;
      try {
        await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
        await mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
        await mapboxMap.attribution.updateSettings(
          AttributionSettings(enabled: false),
        );
        await mapboxMap.scaleBar.updateSettings(
          ScaleBarSettings(enabled: false),
        );
      } catch (e) {
        debugPrint("Mapbox UI settings error: $e");
      }
    });

    try {
      await mapboxMap.location.updateSettings(
        LocationComponentSettings(enabled: true, puckBearingEnabled: true),
      );

      await mapboxMap.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            southwest: Point(coordinates: Position(-180, -90)),
            northeast: Point(coordinates: Position(180, 90)),
            infiniteBounds: true,
          ),
          minZoom: 13.0,
          maxZoom: 21.0,
        ),
      );
    } catch (e) {
      debugPrint("Mapbox 초기 설정 에러: $e");
    }

    if (!mounted) return;

    Future.microtask(() async {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);

      try {
        await mapboxMap.gestures.updateSettings(
          GesturesSettings(
            scrollEnabled: false, // 이동 비활성화
            pinchPanEnabled: false, // 두 손가락 이동 비활성화
            rotateEnabled: true, // 회전 활성화
            pitchEnabled: false, // 3D 기울기 비활성화
            focalPoint: ScreenCoordinate(
              x: size.width / 2.0,
              y: size.height / 2.0,
            ),
          ),
        );
      } catch (e) {
        debugPrint("Mapbox gestures 설정 에러: $e");
      }
    });

    // 지도가 완전히 준비된 후 마커를 추가합니다.
    // 약간의 지연을 주어 플랫폼 채널이 안정화될 시간을 확보합니다.
    _isMapReady = true;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final state = ref.read(homeViewModelProvider);
    final templatesAsync = ref.read(soopkomonTemplatesProvider);
    if (!state.isLoading &&
        state.locations.isNotEmpty &&
        templatesAsync.hasValue) {
      _addMarkers(state.locations, templatesAsync.value!);
    }

    await _applyDayNightTheme(mapboxMap);

    // 지도가 생성된 시점에 이미 위치를 받아왔다면 즉시 1회 이동
    if (currentState.currentPosition != null && !_hasMovedToInitialLocation) {
      _tryMoveToUserLocation(currentState.currentPosition!);
    }
  }

  Future<void> _applyDayNightTheme(MapboxMap mapbox) async {
    final String timePreset = _isNight() ? "night" : "day";
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

  bool _isNight() {
    final int currentHour = DateTime.now().hour;
    return currentHour < 6 || currentHour >= 18;
  }

  Future<void> _tryMoveToUserLocation(
    geo.Position position, {
    bool forceDefaultZoom = false,
  }) async {
    if (mapboxMap == null) return;

    _hasMovedToInitialLocation = true; // 중복 호출 방지

    double targetZoom = _defaultZoomLevel;
    if (!forceDefaultZoom) {
      try {
        final currentCamera = await mapboxMap!.getCameraState();
        targetZoom = currentCamera.zoom;
      } catch (e) {
        debugPrint('[내 위치] getCameraState 오류 무시: $e');
      }
    }

    final point = Point(
      coordinates: Position(position.longitude, position.latitude),
    );
    final cameraOptions = CameraOptions(
      center: point,
      zoom: targetZoom,
      bearing: 0.0,
      pitch: 0.0,
    );

    debugPrint(
      '[디버그] 내 위치로 맵 이동 명령 전송: ${position.latitude}, ${position.longitude}',
    );
    try {
      // 큐에 정상적으로 적재되어, 지도 렌더링이 완료된 후 애니메이션으로 부드럽게 이동합니다.
      await mapboxMap!.flyTo(
        cameraOptions,
        MapAnimationOptions(duration: 1200, startDelay: 0),
      );
    } catch (e) {
      debugPrint('[디버그] 지도 이동 명령 실패: $e');
      _hasMovedToInitialLocation = false; // 실패 시 재시도 할 수 있도록
    }
  }

  void _showLocationDetails(int index) {
    final state = ref.read(homeViewModelProvider);
    final locations = state.locations;
    if (index < 0 || index >= locations.length) return;
    final loc = locations[index];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ParkDetailSheet(
          id: loc.id.toString(),
          name: loc.name,
          description: loc.summary,
          imageUrl: loc.imageUrl,
          imageUrls: loc.imageUrls,
          address: loc.address,
          information: loc.information,
          tel: loc.tel,
          tel1: loc.tel1,
          tel2: loc.tel2,
          isVisited: false,
          naviLoc: loc.naviLoc,
          naviLat: loc.naviLat,
          naviLng: loc.naviLng,
          petIds: loc.petIds,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final friendRequestsAsync = ref.watch(friendRequestProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    final friendRequests = friendRequestsAsync.value ?? [];
    final pendingRequests = friendRequests
        .where(
          (req) => req.status == FriendRequestStatus.pending && !req.notified,
        )
        .toList();

    // 언어 변경 시 마커 갱신 트리거
    ref.listen(localeProvider, (prev, next) {
      if (prev != next && mapboxMap != null && _isMapReady) {
        final currentState = ref.read(homeViewModelProvider);
        final templates = ref.read(soopkomonTemplatesProvider).value;
        if (!currentState.isLoading &&
            currentState.locations.isNotEmpty &&
            templates != null) {
          _addMarkers(currentState.locations, templates);
        }
      }
    });

    // 데이터 로드 완료 및 변경 시 마커 갱신
    ref.listen(homeViewModelProvider.select((s) => s.locations), (prev, next) {
      if (next.isNotEmpty && mapboxMap != null && _isMapReady) {
        final templates = ref.read(soopkomonTemplatesProvider).value;
        if (templates != null) {
          _addMarkers(next, templates);
        }
      }
    });

    ref.listen(mapZoomResetProvider, (_, _) {
      final state = ref.read(homeViewModelProvider);
      if (state.currentPosition != null) {
        _tryMoveToUserLocation(state.currentPosition!, forceDefaultZoom: true);
      }
    });

    // 위치 획득 및 갱신 시 실시간 트래킹 (내가 걷는 대로 지도 중앙 유지)
    ref.listen(homeViewModelProvider.select((s) => s.currentPosition), (
      prev,
      next,
    ) {
      if (next != null && mapboxMap != null) {
        // 앱을 켠 첫 위치 획득 때만 고정 줌(16.5) 사용, 이후 걷는 중일 땐 사용자의 현재 줌 레벨 유지
        _tryMoveToUserLocation(
          next,
          forceDefaultZoom: !_hasMovedToInitialLocation,
        );
      }
    });

    ref.listen(homeViewModelProvider.select((s) => s.lastAcquiredPetName), (
      prev,
      next,
    ) {
      if (next != null) {
        final currentState = ref.read(homeViewModelProvider);
        PetAcquiredDialog.show(
          context,
          petName: next,
          parkName: currentState.lastAcquiredParkName ?? '',
          eggPath:
              currentState.lastAcquiredPetEggPath ??
              Assets.eggMystery,
          isEn: ref.read(localeProvider) == AppLocale.en,
        );
      }
    });

    ref.listen(homeViewModelProvider.select((s) => s.lastHatchedPetName), (
      prev,
      next,
    ) {
      if (next != null) {
        final currentState = ref.read(homeViewModelProvider);
        PetHatchedDialog.show(
          context,
          petName: next,
          parkName: currentState.lastHatchedParkName ?? '',
          imagePath:
              currentState.lastHatchedPetImagePath ??
              Assets.character000Big,
          isEn: ref.read(localeProvider) == AppLocale.en,
        );
      }
    });

    ref.listen(homeViewModelProvider.select((s) => s.lastUnlockedParkName), (
      prev,
      next,
    ) {
      if (next != null) {
        final currentState = ref.read(homeViewModelProvider);
        ParkUnlockedDialog.show(
          context,
          parkName: next,
          imageUrl: currentState.lastUnlockedParkImageUrl ?? '',
          isEn: ref.read(localeProvider) == AppLocale.en,
          onConfirm: () {
            ref.read(homeViewModelProvider.notifier).clearUnlockedPark();
          },
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: null,
        actions: [
          AppBarIcon(
            svgPath: Assets.bell,
            onTap: () {
              ref
                  .read(friendsViewModelProvider.notifier)
                  .markAllPendingRequestsAsNotified();
              context.pushNamed(AppRoute.notifications.name);
            },
            badgeCount: pendingRequests.length,
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (innerContext) {
              return AppBarIcon(
                svgPath: Assets.hamburger,
                onTap: () => showHamburgerMenu(
                  context: innerContext,
                  ref: ref,
                  isEn: isEn,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: AppColors.transparent,
        elevation: 0,
        foregroundColor: AppColors.black,
      ),
      body: state.locations.isEmpty
          ? _buildFullLoading(isEn) // 필수 데이터(장소)가 아예 없을 때만 전체 화면 로딩
          : Stack(
              children: [
                MapWidget(
                  key: const ValueKey("mapWidget"),
                  styleUri:
                      dotenv.env['MAPBOX_STYLE_URI'] ?? MapboxStyles.STANDARD,
                  onMapCreated: _onMapCreated,
                  viewport: null,
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(
                        state.currentPosition?.longitude ??
                            state.locations.first.lng,
                        state.currentPosition?.latitude ??
                            state.locations.first.lat,
                      ),
                    ),
                    zoom: _defaultZoomLevel,
                    pitch: 0.0,
                    bearing: 0.0,
                  ),
                ),
                // 상단 상태 오버레이 (위치 확인 중 또는 에러 표시)
                if (state.currentPosition == null)
                  _buildLocationStatusOverlay(state, ref, isEn),

                Positioned(
                  top: 65,
                  left: 16,
                  child: StepCountCard(state: state, isEn: isEn),
                ),
              ],
            ),
    );
  }

  /// 전체 화면 로딩 (데이터가 아예 없을 때)
  Widget _buildFullLoading(bool isEn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary600),
          const SizedBox(height: 16),
          Text(
            isEn ? 'Loading essential information...' : '필수 정보를 불러오고 있습니다...',
            style: const TextStyle(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  /// 지도 상단에 띄우는 위치 상태 오버레이 (Non-blocking)
  Widget _buildLocationStatusOverlay(
    HomeState state,
    WidgetRef ref,
    bool isEn,
  ) {
    return Positioned(
      top: 120, // StepCountCard 아래 위치
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (state.errorMessage == null)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary600,
                ),
              )
            else
              const Icon(Icons.location_off, color: AppColors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.errorMessage ??
                    (isEn
                        ? 'Checking your location...'
                        : '정확한 내 위치를 확인하고 있습니다...'),
                style: AppTextStyles.label.copyWith(
                  color: state.errorMessage != null
                      ? AppColors.error
                      : AppColors.gray700,
                ),
              ),
            ),
            if (state.errorMessage != null)
              TextButton(
                onPressed: () {
                  ref
                      .read(homeViewModelProvider.notifier)
                      .retryLocationTracking();
                },
                child: Text(isEn ? 'Retry' : '다시 시도'),
              ),
          ],
        ),
      ),
    );
  }
}
