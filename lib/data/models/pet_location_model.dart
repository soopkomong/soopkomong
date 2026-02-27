import '../../domain/entities/pet_location.dart';

/// [Data Layer] - Model
/// Domain Layer의 Entity를 상속받아 외부 데이터(JSON 등)와의 매핑을 담당합니다.
/// API 응답이나 로컬 JSON 형식의 데이터를 시스템 내부 객체로 변환(`fromJson`)하는 역할을 합니다.
class PetLocationModel extends PetLocation {
  const PetLocationModel({
    required super.id,
    required super.region,
    required super.name,
    required super.lat,
    required super.lng,
    required super.petName,
    required super.petType,
  });

  factory PetLocationModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coords'] as Map<String, dynamic>? ?? {};
    final pet = json['pet'] as Map<String, dynamic>? ?? {};

    return PetLocationModel(
      id: json['id'] as int? ?? 0,
      region: json['region'] as String? ?? '알 수 없음',
      name: json['name'] as String? ?? '이름 없음',
      lat: (coords['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (coords['lng'] as num?)?.toDouble() ?? 0.0,
      petName: pet['name'] as String? ?? '알 수 없음',
      petType: pet['type'] as String? ?? '알 수 없음',
    );
  }
}
