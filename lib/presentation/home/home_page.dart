import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/utils/map_helper.dart';
import 'package:soopkomong/core/utils/turf_helper.dart';
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
import 'package:soopkomong/presentation/home/widgets/friend_request_dialog.dart';
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
        final Uint8List markerBytes = await createIconMarkerBitmap(
          Icons.location_pin,
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
            : AppColors.primary500;
        final double fillOpacity = isNight ? 0.3 : 0.2;

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
          minZoom: 14.5,
          maxZoom: 22.0,
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
            scrollEnabled: false,
            pinchPanEnabled: false,
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

  Future<void> _moveToCurrentLocation({bool forceDefaultZoom = false}) async {
    final state = ref.read(homeViewModelProvider);
    final position = state.currentPosition;
    if (position == null) return;

    if (mapboxMap != null) {
      final currentCamera = await mapboxMap!.getCameraState();
      final targetZoom = forceDefaultZoom
          ? _defaultZoomLevel
          : currentCamera.zoom;
      mapboxMap?.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: targetZoom,
        ),
      );
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

    ref.listen(
      mapZoomResetProvider,
      (_, _) => _moveToCurrentLocation(forceDefaultZoom: true),
    );

    ref.listen(homeViewModelProvider.select((s) => s.currentPosition), (
      prev,
      next,
    ) {
      if (next != null && mapboxMap != null) {
        mapboxMap?.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(next.longitude, next.latitude)),
          ),
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
              'assets/images/egg/egg_mystery.png',
          isEn: ref.read(localeProvider) == AppLocale.en,
        );
      }
    });

    ref.listen(
      friendRequestProvider.select(
        (s) => s.value
            ?.where(
              (req) =>
                  req.status == FriendRequestStatus.pending && !req.notified,
            )
            .firstOrNull,
      ),
      (prev, next) {
        if (next != null) {
          FriendRequestDialog.show(
            context,
            nickname: next.senderName,
            photoUrl: next.senderPhotoUrl,
            isEn: ref.read(localeProvider) == AppLocale.en,
            onConfirm: () {
              ref
                  .read(friendsViewModelProvider.notifier)
                  .acceptFriendRequest(next);
            },
            onReject: () {
              ref
                  .read(friendsViewModelProvider.notifier)
                  .declineFriendRequest(next.id);
            },
            onClose: () {
              ref
                  .read(friendsViewModelProvider.notifier)
                  .markNotified(next.id);
            },
          );
        }
      },
    );

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
              'assets/images/characters/000_big.png',
          isEn: ref.read(localeProvider) == AppLocale.en,
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
            svgPath: 'assets/images/bell.svg',
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
                svgPath: 'assets/images/Hamburger.svg',
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
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri: dotenv.env['MAPBOX_STYLE_URI'] ?? MapboxStyles.STANDARD,
            onMapCreated: _onMapCreated,
            viewport: FollowPuckViewportState(
              zoom: _defaultZoomLevel,
              pitch: 0.0,
            ),
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(127.7669, 35.9078)),
              zoom: _defaultZoomLevel,
              pitch: 0.0,
              bearing: 0.0,
            ),
          ),
          Positioned(
            top: 65,
            left: 16,
            child: StepCountCard(state: state, isEn: isEn),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   child: const Icon(Icons.add_location_alt, color: Colors.green),
      //   onPressed: () {
      //     final currentSteps = ref.read(homeViewModelProvider).stepCount;
      //     ref
      //         .read(homeViewModelProvider.notifier)
      //         .updateStepCount(currentSteps + 100);
      //   },
      // ),
    );
  }
}
