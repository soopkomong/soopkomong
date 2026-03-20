import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/repositories/location_repository.dart';
import 'package:soopkomong/domain/usecases/get_locations_usecase.dart';
import 'package:soopkomong/data/repositories/location_repository_impl.dart';
import 'package:soopkomong/data/datasources/local_location_datasource.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:uuid/uuid.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

/// Providers for DI
final locationDataSourceProvider = Provider<LocalLocationDataSource>((ref) {
  return LocalLocationDataSourceImpl();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(ref.watch(locationDataSourceProvider));
});

final getLocationsUseCaseProvider = Provider<GetLocationsUseCase>((ref) {
  return GetLocationsUseCase(ref.watch(locationRepositoryProvider));
});

/// Home State
class HomeState {
  final bool isLoading;
  final List<Location> locations;
  final String? errorMessage;
  final int stepCount;
  final geo.Position? currentPosition;
  final int? currentParkId;
  final int? stepsAtParkEntry;
  final bool isPetAcquiredInCurrentPark;
  final String? lastAcquiredPetName;
  final String? lastAcquiredParkName;
  final String? lastAcquiredPetEggPath;
  final String? lastHatchedPetName;
  final String? lastHatchedParkName;
  final String? lastHatchedPetImagePath;

  HomeState({
    required this.isLoading,
    required this.locations,
    this.errorMessage,
    this.stepCount = 0,
    this.currentPosition,
    this.currentParkId,
    this.stepsAtParkEntry,
    this.isPetAcquiredInCurrentPark = false,
    this.lastAcquiredPetName,
    this.lastAcquiredParkName,
    this.lastAcquiredPetEggPath,
    this.lastHatchedPetName,
    this.lastHatchedParkName,
    this.lastHatchedPetImagePath,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Location>? locations,
    String? errorMessage,
    int? stepCount,
    geo.Position? currentPosition,
    int? currentParkId,
    int? stepsAtParkEntry,
    bool? isPetAcquiredInCurrentPark,
    String? lastAcquiredPetName,
    String? lastAcquiredParkName,
    String? lastAcquiredPetEggPath,
    String? lastHatchedPetName,
    String? lastHatchedParkName,
    String? lastHatchedPetImagePath,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
      stepCount: stepCount ?? this.stepCount,
      currentPosition: currentPosition ?? this.currentPosition,
      currentParkId: currentParkId ?? this.currentParkId,
      stepsAtParkEntry: stepsAtParkEntry ?? this.stepsAtParkEntry,
      isPetAcquiredInCurrentPark:
          isPetAcquiredInCurrentPark ?? this.isPetAcquiredInCurrentPark,
      lastAcquiredPetName: lastAcquiredPetName ?? this.lastAcquiredPetName,
      lastAcquiredParkName: lastAcquiredParkName ?? this.lastAcquiredParkName,
      lastAcquiredPetEggPath:
          lastAcquiredPetEggPath ?? this.lastAcquiredPetEggPath,
      lastHatchedPetName: lastHatchedPetName ?? this.lastHatchedPetName,
      lastHatchedParkName: lastHatchedParkName ?? this.lastHatchedParkName,
      lastHatchedPetImagePath:
          lastHatchedPetImagePath ?? this.lastHatchedPetImagePath,
    );
  }
}

/// [Presentation Layer] - ViewModel (Notifier)
/// 화면(View)에서 보여줄 상태(State)를 관리하고 비즈니스 로직(UseCase)을 호출하는 역할입니다.
/// Riverpod의 [Notifier]를 사용하여 상태 관리를 수행합니다.
class HomeNotifier extends Notifier<HomeState> {
  Timer? _stepTimer;
  StreamSubscription<geo.Position>? _positionSubscription;
  int _debugStepOffset = 0; // 테스트용 수동 걸음 수 증가분


  @override
  HomeState build() {
    debugPrint('[디버그] HomeNotifier build() 호출됨 (상태 초기화)');
    ref.onDispose(() {
      _stepTimer?.cancel();
      _positionSubscription?.cancel();
    });
    return HomeState(isLoading: false, locations: []);
  }

  Future<void> loadData() async {
    debugPrint('[디버그] loadData 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final useCase = ref.read(getLocationsUseCaseProvider);
      final locations = await useCase();
      debugPrint('[디버그] loadData 완료: ${locations.length}개의 위치 로드됨');
      state = state.copyWith(isLoading: false, locations: locations);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '데이터 로드 실패: $e');
    }
  }

  Future<void> startTracking() async {
    // 위치 추적과 건강 데이터 추적을 병렬로 시작하여 초기화 지연 방지
    _startLocationTracking();
    startHealthTracking();
  }

  Future<void> _startLocationTracking() async {
    debugPrint('[디버그] _startLocationTracking 시작');
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(errorMessage: '위치 서비스가 비활성화되어 있습니다.');
      return;
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        state = state.copyWith(errorMessage: '위치 권한이 거부되었습니다.');
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      state = state.copyWith(errorMessage: '위치 권한이 영구적으로 거부되었습니다.');
      return;
    }

    debugPrint('[디버그] 현재 위치 가져오기 시도 중...');
    final initialPosition = await geo.Geolocator.getCurrentPosition();
    debugPrint(
      '[디버그] 초기 위치 획득: ${initialPosition.latitude}, ${initialPosition.longitude}',
    );
    state = state.copyWith(currentPosition: initialPosition);
    _checkParkProximity(initialPosition);

    _positionSubscription =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((geo.Position position) {
          state = state.copyWith(currentPosition: position);
          _checkParkProximity(position);
        });
  }

  void _checkParkProximity(geo.Position position) {
    if (state.locations.isEmpty) return;

    int? detectedParkId;
    for (final loc in state.locations) {
      final distance = geo.Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        loc.lat,
        loc.lng,
      );

      if (distance <= loc.radius) {
        detectedParkId = loc.id;
        debugPrint(
          '[디버그] 공원 범위 내 감지: ${loc.name} (거리: ${distance.toStringAsFixed(1)}m, 반경: ${loc.radius}m)',
        );
        break;
      }
    }

    if (detectedParkId == null && state.locations.isNotEmpty) {
      // 가장 가까운 공원과의 거리 로그 (디버깅용)
      double minDistance = double.infinity;
      String nearestPark = '';
      for (final loc in state.locations) {
        final d = geo.Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          loc.lat,
          loc.lng,
        );
        if (d < minDistance) {
          minDistance = d;
          nearestPark = loc.name;
        }
      }
      debugPrint(
        '[디버그] 현재 공원이 감지되지 않음. 가장 가까운 공원: $nearestPark (거리: ${minDistance.toStringAsFixed(1)}m)',
      );
    }

    if (detectedParkId != state.currentParkId) {
      if (detectedParkId != null) {
        // 새로운 공원 진입
        state = state.copyWith(
          currentParkId: detectedParkId,
          stepsAtParkEntry: state.stepCount,
          isPetAcquiredInCurrentPark: false,
        );
        debugPrint('공원 진입: $detectedParkId, 진입 시 걸음수: ${state.stepCount}');
      } else {
        // 공원에서 벗어남
        state = state.copyWith(
          currentParkId: null,
          stepsAtParkEntry: null,
          isPetAcquiredInCurrentPark: false,
        );
        debugPrint('공원에서 벗어남');
      }
    }
  }

  Future<void> startHealthTracking() async {
    Health().configure();

    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    try {
      bool hasPermissions = await Health().hasPermissions(types, permissions: permissions) ?? false;
      if (!hasPermissions) {
        bool requested = await Health().requestAuthorization(types, permissions: permissions);
        if (!requested) {
          debugPrint('[디버그] 건강 앱 접근 권한이 거부되었습니다.');
          return;
        }
      }

      await _fetchTodaySteps();
      
      _stepTimer?.cancel();
      _stepTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _fetchTodaySteps();
      });
    } catch (error) {
      debugPrint('건강 앱 연동 에러: $error');
      state = state.copyWith(errorMessage: '건강 앱 에러: $error');
    }
  }

  Future<void> _fetchTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      int? steps = await Health().getTotalStepsInInterval(midnight, now);
      if (steps != null) {
        _processNewStepCount(steps + _debugStepOffset);
      }
    } catch (e) {
      debugPrint('걸음 수 조회 실패: $e');
    }
  }

  void _processNewStepCount(int newStepCount) {
    if (newStepCount == state.stepCount) return;

    state = state.copyWith(stepCount: newStepCount);

    if (state.currentParkId != null &&
        !state.isPetAcquiredInCurrentPark &&
        state.stepsAtParkEntry != null) {
      final stepsInPark = newStepCount - state.stepsAtParkEntry!;
      if (stepsInPark >= 100) {
        _acquirePet(state.currentParkId!);
      }
    }

    _checkHatchingCondition(newStepCount);
  }

  Future<void> _acquirePet(int parkId) async {
    debugPrint('[디버그] _acquirePet 시도 - parkId: $parkId');
    final park = state.locations.firstWhere((loc) => loc.id == parkId);
    if (park.petIds.isEmpty) {
      debugPrint('[디버그] _acquirePet 중단: 해당 공원에 설정된 petIds가 없음');
      return;
    }

    final templatesAsync = ref.read(soopkomonTemplatesProvider);
    if (!templatesAsync.hasValue) {
      debugPrint('[디버그] _acquirePet 중단: templatesAsync 데이터가 아직 로드되지 않음');
      return;
    }

    final template = templatesAsync.value!.firstWhere(
      (t) => t.templateId == park.petIds.first,
      orElse: () => templatesAsync.value!.first,
    );

    final newPet = Soopkomon(
      instanceId: const Uuid().v4(),
      templateId: template.templateId,
      name: template.name,
      discoveredSpotId: park.id.toString(),
      discoveredSpotName: park.name,
      discoveredAddr: park.address,
      discoveredAt: DateTime.now(),
      stepsAtDiscovery: state.stepCount,
      currentTotalSteps: state.stepCount,
    );

    ref
        .read(soopkomonRepositoryProvider)
        .addSoopkomon(ref.read(userProvider).value!.id, newPet);
    debugPrint(
      '[디버그] 상태 업데이트 직전: lastAcquiredPetName=${state.lastAcquiredPetName}',
    );
    state = state.copyWith(
      isPetAcquiredInCurrentPark: true,
      lastAcquiredPetName: template.name,
      lastAcquiredParkName: park.name,
      lastAcquiredPetEggPath: template.eggImagePath,
    );
    debugPrint(
      '[디버그] 상태 업데이트 완료: lastAcquiredPetName=${state.lastAcquiredPetName}',
    );
    debugPrint('펫 획득 성공: ${template.name} at ${park.name}');
  }

  /// 획득 팝업 확인 후 상태 초기화
  void clearAcquiredPet() {
    debugPrint('[디버그] clearAcquiredPet() 호출');
    state = state.copyWith(
      lastAcquiredPetName: null,
      lastAcquiredParkName: null,
      lastAcquiredPetEggPath: null,
    );
  }

  void updateStepCount(int count) {
    debugPrint(
      '[디버그] updateStepCount 호출됨: $count (현재 state.stepCount: ${state.stepCount})',
    );
    
    // 수동으로 증가시킨 만큼 오프셋으로 기록하여 폴링 시에도 유지되게 함
    if (count > state.stepCount) {
      _debugStepOffset += (count - state.stepCount);
    }
    
    _processNewStepCount(count);

    // 기존의 updateStepCount 내부 로직은 _processNewStepCount로 이전되었으므로
    // 여기서 직접 _checkHatchingCondition 등을 다시 부를 필요가 없습니다. (이미 _processNewStepCount 안에서 호출함)
  }

  void _checkHatchingCondition(int newStepCount) {
    final userPetsAsync = ref.read(userSoopkomonProvider);
    userPetsAsync.whenData((pets) {
      for (final pet in pets) {
        if (!pet.isHatched && (newStepCount - pet.stepsAtDiscovery) >= 1000) {
          _hatchPet(pet);
          break; // 한 번에 하나의 부화만 처리
        }
      }
    });
  }

  void _hatchPet(Soopkomon pet) {
    final user = ref.read(userProvider).value;
    if (user != null) {
      ref
          .read(soopkomonRepositoryProvider)
          .markSoopkomonAsHatched(user.id, pet.instanceId);
    }
    state = state.copyWith(
      lastHatchedPetName: pet.name,
      lastHatchedParkName: pet.discoveredSpotName,
      lastHatchedPetImagePath: pet.imagePath,
    );
    debugPrint('펫 부화 성공: ${pet.name} from ${pet.discoveredSpotName}');
  }

  void clearHatchedPet() {
    state = state.copyWith(
      lastHatchedPetName: null,
      lastHatchedParkName: null,
      lastHatchedPetImagePath: null,
    );
  }
}

final homeViewModelProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

/// 맵 줌 리셋 이벤트를 알리기 위한 Notifier
class MapZoomResetNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void triggerReset() {
    state++;
  }
}

final mapZoomResetProvider = NotifierProvider<MapZoomResetNotifier, int>(() {
  return MapZoomResetNotifier();
});
