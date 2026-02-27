import '../../domain/entities/pet_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/local_location_datasource.dart';

/// [Data Layer] - Repository Implementation
/// Domain Layer에서 정의된 [LocationRepository] 인터페이스를 실제로 구현합니다.
/// DataSource를 호출하여 원시 데이터를 가져오고, 이를 Domain Layer에서 사용할 수 있도록 제공합니다.
class LocationRepositoryImpl implements LocationRepository {
  final LocalLocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<List<PetLocation>> getLocations() async {
    return await dataSource.getLocalLocations();
  }
}
