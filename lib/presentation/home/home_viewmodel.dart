import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';

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
class HomeNotifier extends Notifier<HomeState> {
  StreamSubscription<geo.Position>? _positionSubscription;
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  HomeState build() {
    // 전역 locationsProvider를 감시하여 언어 변경 시 상태 자동 갱신
    ref.listen(locationsProvider, (prev, next) {
      next.whenData((locations) {
        state = state.copyWith(
          locations: locations,
          isLoading: false,
        );
      });
    });

    final locationsAsync = ref.watch(locationsProvider);

    ref.onDispose(() {
      _stepSubscription?.cancel();
      _positionSubscription?.cancel();
    });

    return HomeState(
      isLoading: locationsAsync.isLoading,
      locations: locationsAsync.value ?? [],
    );
  }

  /// 데이터 로드 (실제로는 build에서 초기값 설정 및 감시 중이므로 수동 트리거용)
  Future<void> loadData() async {
    final locationsAsync = ref.read(locationsProvider);
    if (locationsAsync.hasValue) {
      state = state.copyWith(
        locations: locationsAsync.value,
        isLoading: false,
      );
    }
  }

  Future<void> startTracking() async {
    await startPedometer();
    await _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
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

    final initialPosition = await geo.Geolocator.getCurrentPosition();
    state = state.copyWith(currentPosition: initialPosition);
    _checkParkProximity(initialPosition);

    _positionSubscription = geo.Geolocator.getPositionStream(
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
        break;
      }
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

  Future<void> startPedometer() async {
    // 권한 요청
    final status = Platform.isIOS
        ? await Permission.sensors.request()
        : await Permission.activityRecognition.request();

    if (status.isGranted) {
      _stepSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          final newStepCount = event.steps;
          state = state.copyWith(stepCount: newStepCount);

          // 펫 획득 조건 체크 (공원 내 100걸음)
          if (state.currentParkId != null &&
              !state.isPetAcquiredInCurrentPark &&
              state.stepsAtParkEntry != null) {
            final stepsInPark = newStepCount - state.stepsAtParkEntry!;
            if (stepsInPark >= 100) {
              _acquirePet(state.currentParkId!);
            }
          }

          // 부화 조건 체크 (모든 보유 펫 대상)
          _checkHatchingCondition(newStepCount);
        },
        onError: (error) {
          debugPrint('만보기 스트림 에러: $error');
          // 에러 발생 시(특히 지원되지 않는 기기) 불필요한 반복 호출을 막기 위해 구독 취소
          _stepSubscription?.cancel();
          _stepSubscription = null;

          if (Platform.isIOS) {
            // iOS에서 Step Count 사용 불가 시 별도 에러 메시지 없이 무시
            // (시뮬레이터 등 기능 미지원 환경 대응)
          } else {
            state = state.copyWith(errorMessage: '만보기 에러: $error');
          }
        },
      );
    } else {
      if (!Platform.isIOS) {
        state = state.copyWith(errorMessage: '신체 활동 권한이 거부되었습니다.');
      }
    }
  }

  Future<void> _acquirePet(int parkId) async {
    final park = state.locations.firstWhere((loc) => loc.id == parkId);
    if (park.petIds.isEmpty) return;

    final templatesAsync = ref.read(soopkomonTemplatesProvider);
    if (!templatesAsync.hasValue) return;

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

    ref.read(userSoopkomonProvider.notifier).add(newPet);
    state = state.copyWith(
      isPetAcquiredInCurrentPark: true,
      lastAcquiredPetName: template.name,
      lastAcquiredParkName: park.name,
      lastAcquiredPetEggPath: template.eggImagePath,
    );
    debugPrint('펫 획득 성공: ${template.name} at ${park.name}');
  }

  void updateStepCount(int count) {
    state = state.copyWith(stepCount: count);

    // 보유 펫 걸음 수 동기화
    ref.read(userSoopkomonProvider.notifier).updateAllSteps(count);

    // 수동 업데이트 시에도 펫 획득 조건 체크
    if (state.currentParkId != null &&
        !state.isPetAcquiredInCurrentPark &&
        state.stepsAtParkEntry != null) {
      final stepsInPark = count - state.stepsAtParkEntry!;
      if (stepsInPark >= 100) {
        _acquirePet(state.currentParkId!);
      }
    }

    // 부화 조건 체크
    _checkHatchingCondition(count);
  }

  void _checkHatchingCondition(int newStepCount) {
    final userPets = ref.read(userSoopkomonProvider);
    for (final pet in userPets) {
      if (!pet.isHatched && (newStepCount - pet.stepsAtDiscovery) >= 1000) {
        _hatchPet(pet);
        break; // 한 번에 하나의 부화만 처리 (다이얼로그 겹침 방지)
      }
    }
  }

  void _hatchPet(Soopkomon pet) {
    ref.read(userSoopkomonProvider.notifier).markAsHatched(pet.instanceId);
    state = state.copyWith(
      lastHatchedPetName: pet.name,
      lastHatchedParkName: pet.discoveredSpotName,
      lastHatchedPetImagePath: pet.imagePath,
    );
    debugPrint('펫 부화 성공: ${pet.name} from ${pet.discoveredSpotName}');
  }

  void clearAcquiredPet() {
    state = state.copyWith(
      lastAcquiredPetName: null,
      lastAcquiredParkName: null,
      lastAcquiredPetEggPath: null,
    );
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
