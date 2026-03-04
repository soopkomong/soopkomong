import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/pet_location.dart';
import 'package:soopkomong/domain/repositories/location_repository.dart';
import 'package:soopkomong/domain/usecases/get_locations_usecase.dart';
import 'package:soopkomong/data/repositories/location_repository_impl.dart';
import 'package:soopkomong/data/datasources/local_location_datasource.dart';

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
  final List<PetLocation> locations;
  final String? errorMessage;

  HomeState({
    required this.isLoading,
    required this.locations,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    List<PetLocation>? locations,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// [Presentation Layer] - ViewModel (Notifier)
/// 화면(View)에서 보여줄 상태(State)를 관리하고 비즈니스 로직(UseCase)을 호출하는 역할입니다.
/// Riverpod의 [Notifier]를 사용하여 상태 관리를 수행합니다.
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
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
