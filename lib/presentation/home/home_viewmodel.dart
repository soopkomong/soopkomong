import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/repositories/location_repository.dart';
import 'package:soopkomong/domain/usecases/get_locations_usecase.dart';
import 'package:soopkomong/data/repositories/location_repository_impl.dart';
import 'package:soopkomong/data/datasources/local_location_datasource.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

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

  HomeState({
    required this.isLoading,
    required this.locations,
    this.errorMessage,
    this.stepCount = 0,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Location>? locations,
    String? errorMessage,
    int? stepCount,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
      stepCount: stepCount ?? this.stepCount,
    );
  }
}

/// [Presentation Layer] - ViewModel (Notifier)
/// 화면(View)에서 보여줄 상태(State)를 관리하고 비즈니스 로직(UseCase)을 호출하는 역할입니다.
/// Riverpod의 [Notifier]를 사용하여 상태 관리를 수행합니다.
class HomeNotifier extends Notifier<HomeState> {
  StreamSubscription<StepCount>? _subscription;

  @override
  HomeState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return HomeState(isLoading: false, locations: []);
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final useCase = ref.read(getLocationsUseCaseProvider);
      final locations = await useCase();
      state = state.copyWith(isLoading: false, locations: locations);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '데이터 로드 실패: $e');
    }
  }

  Future<void> startPedometer() async {
    // 권한 요청
    if (await Permission.activityRecognition.request().isGranted) {
      _subscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          state = state.copyWith(stepCount: event.steps);
        },
        onError: (error) {
          state = state.copyWith(errorMessage: '만보기 에러: $error');
        },
      );
    } else {
      state = state.copyWith(errorMessage: '신체 활동 권한이 거부되었습니다.');
    }
  }

  void updateStepCount(int count) {
    state = state.copyWith(stepCount: count);
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
