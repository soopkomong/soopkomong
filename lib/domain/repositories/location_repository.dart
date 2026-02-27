import '../entities/pet_location.dart';

/// [Domain Layer] - Repository Interface
/// Data Layer와 소통하기 위한 인터페이스입니다.
/// 의존성 역전 원칙(DIP)을 적용하여, Domain Layer가 Data Layer의 구체적인 구현(Impl)에
/// 의존하지 않도록 계약(Contract)을 정의합니다.
abstract class LocationRepository {
  Future<List<PetLocation>> getLocations();
}
