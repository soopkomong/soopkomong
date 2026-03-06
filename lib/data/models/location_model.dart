import 'package:soopkomong/domain/entities/location.dart';

/// [Data Layer] - Model
/// Domain Layer의 Entity를 상속받아 외부 데이터(JSON 등)와의 매핑을 담당합니다.
/// API 응답이나 로컬 JSON 형식의 데이터를 시스템 내부 객체로 변환(`fromJson`)하는 역할을 합니다.
class LocationModel extends Location {
  const LocationModel({
    required super.id,
    required super.region,
    required super.name,
    required super.lat,
    required super.lng,
    required super.petName,
    required super.petType,
    required super.radius,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'] as Map<String, dynamic>? ?? {};

    return LocationModel(
      id: int.tryParse(json['contentId']?.toString() ?? '') ?? 0,
      region: json['region'] as String? ?? '알 수 없음',
      name: json['title'] as String? ?? '이름 없음',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      petName: pet['name'] as String? ?? '알 수 없음',
      petType: pet['type'] as String? ?? '알 수 없음',
      radius: (json['radius'] as num?)?.toDouble() ?? 500.0,
    );
  }
}
