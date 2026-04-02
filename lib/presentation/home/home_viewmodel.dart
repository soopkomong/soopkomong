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
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/core/background_service.dart';

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
  final String? lastUnlockedParkName;
  final String? lastUnlockedParkImageUrl;
  final int totalStepCount; // 누적 걸음수 추가

  HomeState({
    required this.isLoading,
    required this.locations,
    this.errorMessage,
    this.stepCount = 0,
    this.totalStepCount = 0, // 초기값 설정
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
    this.lastUnlockedParkName,
    this.lastUnlockedParkImageUrl,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Location>? locations,
    String? errorMessage,
    int? stepCount,
    int? totalStepCount,
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
    String? lastUnlockedParkName,
    String? lastUnlockedParkImageUrl,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
      stepCount: stepCount ?? this.stepCount,
      totalStepCount: totalStepCount ?? this.totalStepCount,
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
      lastUnlockedParkName: lastUnlockedParkName ?? this.lastUnlockedParkName,
      lastUnlockedParkImageUrl:
          lastUnlockedParkImageUrl ?? this.lastUnlockedParkImageUrl,
    );
  }
}

/// [Presentation Layer] - ViewModel (Notifier)
class HomeNotifier extends Notifier<HomeState> {
  StreamSubscription<geo.Position>? _positionSubscription;
  StreamSubscription<StepCount>? _stepSubscription;
  int _lastSyncedSteps = 0;
  bool _isLocationTrackingInProgress = false; // 위치 추적 중복 실행 방지 가드
  Timer? _watchdogTimer; // 10초 강제 타임아웃용 워치독 타이머

  @override
  HomeState build() {
    // 1. 장소 데이터 리스너 등록 (watch 대신 listen 사용)
    // 이를 통해 locationsProvider가 업데이트되어도 HomeNotifier 자체가 리빌드(상태 초기화)되지 않음
    ref.listen(locationsProvider, (prev, next) {
      next.whenData((locations) {
        if (state.locations.isEmpty ||
            state.locations.length != locations.length) {
          state = state.copyWith(locations: locations, isLoading: false);
        }
      });
    });

    // 2. 초기 데이터 및 자원 해제 설정
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _stepSubscription?.cancel();
      _watchdogTimer?.cancel();
    });

    // 3. 초기 상태 반환 (기존 데이터가 있으면 유지, 없으면 빈 상태로 시작)
    final initialLocations = ref.read(locationsProvider).value ?? [];

    return HomeState(
      isLoading: initialLocations.isEmpty,
      locations: initialLocations,
      errorMessage: null, // 초기화 시 에러 메시지 초기화
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

    // 앱 재설치 등 로컬 누적 걸음수가 0일 경우, Firestore(AppUser) 데이터 기반으로 복구
    final user = ref.read(userProvider).value;
    if (user != null) {
      final localTotal = await stepRepo.getTotalSteps();
      if (localTotal == 0 && user.totalSteps > 0) {
        debugPrint(
          '[디버그] 로컬 총 걸음수가 0이므로 Firestore의 totalSteps(${user.totalSteps})로 동기화합니다.',
        );
        await stepRepo.setTotalSteps(user.totalSteps);
        _lastSyncedSteps = user.totalSteps;
      } else {
        _lastSyncedSteps = localTotal;
      }
    }

    final initialTodaySteps = await stepRepo.getTodaySteps();
    final initialTotalSteps = await stepRepo.getTotalSteps();
    state = state.copyWith(
      stepCount: initialTodaySteps,
      totalStepCount: initialTotalSteps,
    );
    debugPrint(
      '[디버그] 초기값 - 오늘: ${state.stepCount}, 총: ${state.totalStepCount}',
    );

    // 위치 추적과 걸음 수 추적 시작
    await _startLocationTracking();
    _startPedometerTracking();
    _listenToUserForTutorialEgg();

    // 백그라운드 서비스 안전 시작 (권한 체크 포함)
    startBackgroundServiceSafe();
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

        final stepRepo = ref.read(stepRepositoryProvider);
        final currentTotal = await stepRepo.getTotalSteps();

        final tutorialEgg = Soopkomon.tutorialEgg(currentTotal);
        await ref
            .read(soopkomonRepositoryProvider)
            .addSoopkomon(userId, tutorialEgg);
        debugPrint('[디버그] 튜토리얼 알(000) 지급 완료.');
      } else {
        debugPrint('[디버그] 튜토리얼 알(000) 이미 보유 중.');
      }
    } catch (e) {
      debugPrint('[디버그] 튜토리얼 알 체크 중 에러: $e');
    }
  }

  Future<void> _startLocationTracking() async {
    if (_isLocationTrackingInProgress) {
      debugPrint('[디버그] 이미 위치 추적이 진행 중입니다. 호출을 건너뜀');
      return;
    }

    _isLocationTrackingInProgress = true;

    // 10초 워치독 타이머 시작: 어떤 이유로든 10초 내에 완료되지 않으면 강제로 에러 출력
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(seconds: 10), () {
      if (_isLocationTrackingInProgress && state.currentPosition == null) {
        debugPrint('[디버그] 워치독 작동: 10초 초과로 강제 에러 처리');
        final isEn = ref.read(localeProvider) == AppLocale.en;
        state = state.copyWith(
          errorMessage: isEn
              ? 'Location check is taking too long. Please try again in an open area.'
              : '위치 확인에 시간이 너무 오래 걸립니다. 트인 곳에서 다시 시도해 보세요.',
          isLoading: false,
        );
        _isLocationTrackingInProgress = false;
      }
    });

    bool serviceEnabled;
    geo.LocationPermission permission;

    try {
      // 1. 위치 서비스 활성화 여부 확인 (5초 타임아웃)
      serviceEnabled = await geo.Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!serviceEnabled) {
        final isEn = ref.read(localeProvider) == AppLocale.en;
        state = state.copyWith(
          errorMessage: isEn
              ? 'Location services are disabled. Please turn on GPS in settings.'
              : '위치 서비스가 비활성화되어 있습니다. 설정에서 GPS를 켜주세요.',
        );
        return;
      }

      // 2. 위치 권한 확인 및 요청 (각 5초 타임아웃)
      permission = await geo.Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => geo.LocationPermission.denied,
      );

      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission().timeout(
          const Duration(seconds: 5),
          onTimeout: () => geo.LocationPermission.denied,
        );
        if (permission == geo.LocationPermission.denied) {
          final isEn = ref.read(localeProvider) == AppLocale.en;
          state = state.copyWith(
            errorMessage: isEn
                ? 'Location permission denied. Please allow permission for smooth use.'
                : '위치 권한이 거부되었습니다. 원활한 이용을 위해 권한을 허용해주세요.',
          );
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        final isEn = ref.read(localeProvider) == AppLocale.en;
        state = state.copyWith(
          errorMessage: isEn
              ? 'Location permission permanently denied.\nPlease change permissions in app settings.'
              : '위치 권한이 영구적으로 거부되었습니다.\n앱 설정에서 권한을 변경해주세요.',
        );
        return;
      }

      // 3. 내 위치 파악
      debugPrint('[디버그] 현재 위치 가져오기 시도 중...');

      // 3-1. 마지막 알려진 위치 시도 (지도를 먼저 보여주기 위함)
      try {
        final lastPosition = await geo.Geolocator.getLastKnownPosition()
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        if (lastPosition != null) {
          state = state.copyWith(currentPosition: lastPosition);
          _checkParkProximity(lastPosition);
        }
      } catch (e) {
        debugPrint('[디버그] 마지막 위치 가져오기 실패: $e');
      }

      // 3-2. 실시간 위치 가져오기
      try {
        final position =
            await geo.Geolocator.getCurrentPosition(
              locationSettings: const geo.LocationSettings(
                accuracy: geo.LocationAccuracy.high,
              ),
            ).timeout(
              const Duration(seconds: 8), // 워치독보다 약간 짧게 설정
              onTimeout: () {
                throw TimeoutException('GPS 응답 시간 초과');
              },
            );

        state = state.copyWith(currentPosition: position, errorMessage: null);
        _checkParkProximity(position);

        // 성공 시 워치독 취소
        _watchdogTimer?.cancel();
      } catch (e) {
        debugPrint('[디버그] 실시간 위치 가져오기 최종 오류: $e');
        if (state.currentPosition == null) {
          final isEn = ref.read(localeProvider) == AppLocale.en;
          state = state.copyWith(
            errorMessage: isEn
                ? 'Could not get location information. GPS signals may be weak in the bushes. Please try again in an open area.'
                : '위치 정보를 가져올 수 없습니다. 수풀 속에서는 GPS 신호가 약할 수 있습니다. 트인 곳에서 다시 시도해주세요.',
          );
        }
      }

      // 4. 위치 스트림 구독 (실시간 이동 트래킹)
      _positionSubscription?.cancel();
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
    } catch (e) {
      debugPrint('[디버그] 위치 추적 로직 전체 오류: $e');
      if (state.currentPosition == null && state.errorMessage == null) {
        final isEn = ref.read(localeProvider) == AppLocale.en;
        state = state.copyWith(
          errorMessage: isEn
              ? 'An unknown error occurred while retrieving location information.'
              : '알 수 없는 오류가 발생하여 위치 정보를 가져오지 못했습니다.',
        );
      }
    } finally {
      // 어떤 경로로든 함수가 종료될 때 반드시 잠금을 해제하고 로딩 상태를 종료함
      _isLocationTrackingInProgress = false;
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }

      // 위치 획득 성공 시 워치독 취소
      if (state.currentPosition != null) {
        _watchdogTimer?.cancel();
      }
    }
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
        final park = state.locations.firstWhere(
          (loc) => loc.id == detectedParkId,
        );

        // 유저의 잠금 해제 이력 확인 (알 획득 방식과 동일하게 유저의 unlockedParkIds 체크)
        final user = ref.read(userProvider).value;
        final isAlreadyUnlocked =
            user?.unlockedParkIds.contains(detectedParkId) ?? false;

        state = state.copyWith(
          currentParkId: detectedParkId,
          stepsAtParkEntry: state.stepCount,
          isPetAcquiredInCurrentPark: false,
          // 이미 잠금 해제된 공원이면 팝업 데이터 노출 안 함
          lastUnlockedParkName: isAlreadyUnlocked ? null : park.name,
          lastUnlockedParkImageUrl: isAlreadyUnlocked ? null : park.imageUrl,
        );

        // 처음 방문이면 이력 기록
        if (user != null && !isAlreadyUnlocked) {
          _recordParkUnlock(user.id, detectedParkId);
        }

        debugPrint(
          '공원 진입: $detectedParkId (${park.name}), 이미 잠금해제됨: $isAlreadyUnlocked',
        );
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

    state = state.copyWith(
      stepCount: stepData.todaySteps,
      totalStepCount: stepData.totalSteps,
    );

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

    _syncTotalStepsToFirestore(stepData.totalSteps);

    // 부화 조건 체크 및 개별 숲코몽 걸음수 실시간 동기화
    _checkHatchingCondition(stepData.totalSteps);
  }

  void _syncTotalStepsToFirestore(int currentTotalSteps) {
    if (_lastSyncedSteps == 0) {
      _lastSyncedSteps = currentTotalSteps;
    } else if (currentTotalSteps - _lastSyncedSteps >= 100) {
      _lastSyncedSteps = currentTotalSteps;
      final user = ref.read(userProvider).value;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({
              'totalSteps': currentTotalSteps,
              'lastStepUpdateAt': FieldValue.serverTimestamp(),
            })
            .catchError((e) => debugPrint('[디버그] Firestore 걸음수 동기화 에러: $e'));
      }
    }
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

  Future<void> _checkHatchingCondition(int currentTotalSteps) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    final useCase = ref.read(checkHatchingUseCaseProvider);

    // 이 유즈케이스 내부에서 모든 숲코몽의 currentTotalSteps를 업데이트함
    final hatchedPets = await useCase.execute(user.id, currentTotalSteps);

    if (hatchedPets.isNotEmpty) {
      final pet = hatchedPets.first;
      state = state.copyWith(
        lastHatchedPetName: pet.name,
        lastHatchedParkName: pet.discoveredSpotName,
        lastHatchedPetImagePath: pet.imagePath,
      );
    }
  }

  /// 기존의 개별 부화 처리 함수는 UseCase 내부로 이동됨
  void clearHatchedPet() {
    state = state.copyWith(
      lastHatchedPetName: null,
      lastHatchedParkName: null,
      lastHatchedPetImagePath: null,
    );
  }

  /// 공원 잠금해제 팝업 확인 후 상태 초기화
  void clearUnlockedPark() {
    debugPrint('[디버그] clearUnlockedPark() 호출');
    state = state.copyWith(
      lastUnlockedParkName: null,
      lastUnlockedParkImageUrl: null,
    );
  }

  /// 공원 잠금해제 이력 기록
  Future<void> _recordParkUnlock(String userId, int parkId) async {
    try {
      final user = ref.read(userProvider).value;
      if (user == null) return;

      // 이미 리스트에 있는지 한 번 더 방어적 체크
      if (user.unlockedParkIds.contains(parkId)) return;

      final updatedIds = [...user.unlockedParkIds, parkId];
      await ref
          .read(authRepositoryProvider)
          .updateUnlockedParks(userId, updatedIds);

      debugPrint('[디버그] 공원 잠금 해제 이력 업데이트 성공: $parkId');
    } catch (e) {
      debugPrint('[디버그] 공원 잠금 해제 이력 업데이트 에러: $e');
    }
  }

  /// 위치 정보 수동 재시도
  Future<void> retryLocationTracking() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _startLocationTracking();
    state = state.copyWith(isLoading: false);
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
