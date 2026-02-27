import '../entities/pet_location.dart';
import '../repositories/location_repository.dart';

/// [Domain Layer] - UseCase
/// 특정 비즈니스 흐름(위치 정보 가져오기)을 전담하는 단일 책임 클래스입니다.
/// Repository 인터페이스를 통해 데이터를 가져와 Presentation Layer에 전달합니다.
class GetLocationsUseCase {
  final LocationRepository repository;

  GetLocationsUseCase(this.repository);

  Future<List<PetLocation>> call() async {
    return await repository.getLocations();
  }
}
