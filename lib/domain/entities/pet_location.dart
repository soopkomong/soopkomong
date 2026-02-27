/// [Domain Layer] - Entity
/// 시스템의 핵심 데이터 구조체입니다.
/// 외부 프레임워크나 라이브러리에 의존하지 않는 순수한 Dart 클래스로,
/// 비즈니스 로직에서 사용되는 PetLocation 데이터를 정의합니다.
class PetLocation {
  final int id;
  final String region;
  final String name;
  final double lat;
  final double lng;
  final String petName;
  final String petType;

  const PetLocation({
    required this.id,
    required this.region,
    required this.name,
    required this.lat,
    required this.lng,
    required this.petName,
    required this.petType,
  });
}
