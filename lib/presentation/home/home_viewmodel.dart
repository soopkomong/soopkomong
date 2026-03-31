import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:pedometer/pedometer.dart';
import 'package:uuid/uuid.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/repositories/step_repository.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/step_provider.dart';

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
        state = state.copyWith(locations: locations, isLoading: false);
      });
    });

    final locationsAsync = ref.watch(locationsProvider);

    ref.onDispose(() {
      _positionSubscription?.cancel();
      _stepSubscription?.cancel();
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
      state = state.copyWith(locations: locationsAsync.value, isLoading: false);
    }
  }

  Future<void> startTracking() async {
    // 앱 시작 시 초기 걸음수 로드
    final stepRepo = ref.read(stepRepositoryProvider);
    final initialTodaySteps = await stepRepo.getTodaySteps();
    state = state.copyWith(stepCount: initialTodaySteps);
    print(state.stepCount);

    // 위치 추적과 걸음 수 추적 시작
    _startLocationTracking();
    _startPedometerTracking();
    _listenToUserForTutorialEgg();
  }

  void _listenToUserForTutorialEgg() {
    // 유저 상태 변화를 감시하여 튜토리얼 알 자동 지급
    ref.listen(userProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _checkAndGrantTutorialEgg(user.id);
      }
    }, fireImmediately: true);
  }

  Future<void> _checkAndGrantTutorialEgg(String userId) async {
    try {
      final pets = await ref.read(userSoopkomonProvider.future);
      final hasTutorialEgg = pets.any((p) => p.templateId == '000');
      
      if (!hasTutorialEgg) {
        debugPrint('[디버그] 튜토리얼 알(000) 미보유 감지. 자동 지급 프로세스 시작 (UserID: $userId)');
        final tutorialEgg = Soopkomon.tutorialEgg();
        await ref.read(soopkomonRepositoryProvider).addSoopkomon(userId, tutorialEgg);
        debugPrint('[디버그] 튜토리얼 알(000) 지급 완료.');
      } else {
        debugPrint('[디버그] 튜토리얼 알(000) 이미 보유 중.');
      }
    } catch (e) {
      debugPrint('[디버그] 튜토리얼 알 체크 중 에러: $e');
    }
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
        state = state.copyWith(
          currentParkId: detectedParkId,
          stepsAtParkEntry: state.stepCount,
          isPetAcquiredInCurrentPark: false,
        );
        debugPrint('공원 진입: $detectedParkId, 진입 시 걸음수: ${state.stepCount}');
      } else {
        state = state.copyWith(
          currentParkId: null,
          stepsAtParkEntry: null,
          isPetAcquiredInCurrentPark: false,
        );
        debugPrint('공원에서 벗어남');
      }
    }
  }

  void _startPedometerTracking() {
    _stepSubscription?.cancel();
    _stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        final stepRepo = ref.read(stepRepositoryProvider);
        final stepData = await stepRepo.updateFromPedometer(event.steps);
        _processNewStepCount(stepData);
      },
      onError: (error) {
        debugPrint('[디버그] 걸음 수 스트림 에러: $error');
      },
    );
  }

  void _processNewStepCount(StepData stepData) {
    if (stepData.todaySteps == state.stepCount) return;

    state = state.copyWith(stepCount: stepData.todaySteps);

    if (state.currentParkId != null &&
        !state.isPetAcquiredInCurrentPark &&
        state.stepsAtParkEntry != null) {
      // 공원 진입 시 걸음수와의 차이 계산 (이 로직은 오늘 걸음수 기준으로 할지 누적 기준으로 할지 결정 필요)
      // 여기서는 획득 로직의 일관성을 위해 일단 오늘 걸음수 기준으로 유지 (공원 내에서 100보 걷기)
      final stepsInPark = stepData.todaySteps - state.stepsAtParkEntry!;
      if (stepsInPark >= 100) {
        _acquirePet(state.currentParkId!, stepData.totalSteps);
      }
    }

    _checkHatchingCondition(stepData.totalSteps);
  }

  Future<void> _acquirePet(int parkId, int currentTotalSteps) async {
    debugPrint('[디버그] _acquirePet 시도 - parkId: $parkId');
    final park = state.locations.firstWhere((loc) => loc.id == parkId);
    if (park.petIds.isEmpty) {
      debugPrint('[디버그] _acquirePet 중단: 해당 공원에 설정된 petIds가 없음');
      return;
    }

    // 이미 해당 templateId 보유 중이면 스킵
    final userPets = ref.read(userSoopkomonProvider).value ?? [];
    final alreadyHas = userPets.any((p) => p.templateId == park.petIds.first);
    if (alreadyHas) {
      debugPrint('[디버그] _acquirePet 중단: 이미 보유한 숲코몽');
      state = state.copyWith(isPetAcquiredInCurrentPark: true);
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
      stepsAtDiscovery: currentTotalSteps, // 누적 걸음수를 베이스라인으로 저장
      currentTotalSteps: currentTotalSteps,
      grade: template.grade,
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

  void updateStepCount(StepData data) {
    _processNewStepCount(data);
  }

  void _checkHatchingCondition(int currentTotalSteps) {
    final userPetsAsync = ref.read(userSoopkomonProvider);
    userPetsAsync.whenData((pets) {
      for (final pet in pets) {
        if (!pet.isHatched &&
            (currentTotalSteps - pet.stepsAtDiscovery) >= pet.requiredSteps) {
          _hatchPet(pet);
          break;
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
