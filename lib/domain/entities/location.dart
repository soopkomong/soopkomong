/// [Domain Layer] - Entity
/// 시스템의 핵심 데이터 구조체입니다.
/// 외부 프레임워크나 라이브러리에 의존하지 않는 순수한 Dart 클래스로,
/// 비즈니스 로직에서 사용되는 PetLocation 데이터를 정의합니다.
class Location {
  final int id;
  final String region;
  final String name;
  final double lat;
  final double lng;
  final List<String> petIds;
  final double radius;
  final String imageUrl;
  final String address;
  final String summary;
  final String information;
  final String tel;
  final String naviLoc;
  final double? naviLat;
  final double? naviLng;

  const Location({
    required this.id,
    required this.region,
    required this.name,
    required this.lat,
    required this.lng,
    required this.petIds,
    required this.radius,
    this.imageUrl = '',
    this.address = '',
    this.summary = '',
    this.information = '',
    this.tel = '',
    this.naviLoc = '',
    this.naviLat,
    this.naviLng,
  });
}
