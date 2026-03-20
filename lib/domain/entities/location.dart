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
  final List<String> imageUrls;
  final String address;
  final String summary;
  final String information;
  final String tel;
  final String tel1;
  final String tel2;
  final String naviLoc;
  final double? naviLat;
  final double? naviLng;
  final bool isVisited;

  const Location({
    required this.id,
    required this.region,
    required this.name,
    required this.lat,
    required this.lng,
    required this.petIds,
    required this.radius,
    this.imageUrl = '',
    this.imageUrls = const [],
    this.address = '',
    this.summary = '',
    this.information = '',
    this.tel = '',
    this.tel1 = '',
    this.tel2 = '',
    this.naviLoc = '',
    this.naviLat,
    this.naviLng,
    this.isVisited = false,
  });

  Location copyWith({
    int? id,
    String? region,
    String? name,
    double? lat,
    double? lng,
    List<String>? petIds,
    double? radius,
    String? imageUrl,
    List<String>? imageUrls,
    String? address,
    String? summary,
    String? information,
    String? tel,
    String? tel1,
    String? tel2,
    String? naviLoc,
    double? naviLat,
    double? naviLng,
    bool? isVisited,
  }) {
    return Location(
      id: id ?? this.id,
      region: region ?? this.region,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      petIds: petIds ?? this.petIds,
      radius: radius ?? this.radius,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      address: address ?? this.address,
      summary: summary ?? this.summary,
      information: information ?? this.information,
      tel: tel ?? this.tel,
      tel1: tel1 ?? this.tel1,
      tel2: tel2 ?? this.tel2,
      naviLoc: naviLoc ?? this.naviLoc,
      naviLat: naviLat ?? this.naviLat,
      naviLng: naviLng ?? this.naviLng,
      isVisited: isVisited ?? this.isVisited,
    );
  }
}
