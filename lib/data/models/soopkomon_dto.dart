import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';

class SoopkomonDto extends Soopkomon {
  SoopkomonDto({
    required super.instanceId,
    required super.templateId,
    required super.name,
    required super.discoveredSpotId,
    required super.discoveredSpotName,
    required super.discoveredAddr,
    required super.discoveredAt,
    required super.stepsAtDiscovery,
    super.currentTotalSteps = 0,
    super.isHatched = false,
    super.grade = 'C',
  });

  factory SoopkomonDto.fromEntity(Soopkomon entity) {
    return SoopkomonDto(
      instanceId: entity.instanceId,
      templateId: entity.templateId,
      name: entity.name,
      discoveredSpotId: entity.discoveredSpotId,
      discoveredSpotName: entity.discoveredSpotName,
      discoveredAddr: entity.discoveredAddr,
      discoveredAt: entity.discoveredAt,
      stepsAtDiscovery: entity.stepsAtDiscovery,
      currentTotalSteps: entity.currentTotalSteps,
      isHatched: entity.isHatched,
      grade: entity.grade,
    );
  }

  /// Firestore 데이터에서 객체 생성
  factory SoopkomonDto.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTime = DateTime.now();
    final rawTime = map['discoveredAt'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      try {
        parsedTime = DateTime.parse(rawTime);
      } catch (_) {}
    }

    return SoopkomonDto(
      instanceId: id,
      templateId: map['templateId'] ?? '',
      name: map['name'] ?? '',
      discoveredSpotId: map['discoveredSpotId'] ?? '',
      discoveredSpotName: map['discoveredSpotName'] ?? '',
      discoveredAddr: map['discoveredAddr'] ?? '',
      discoveredAt: parsedTime,
      stepsAtDiscovery: map['stepsAtDiscovery'] ?? 0,
      currentTotalSteps: map['currentTotalSteps'] ?? 0,
      isHatched: map['isHatched'] ?? false,
      grade: map['grade'] ?? 'C',
    );
  }

  /// Firestore 저장을 위한 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'templateId': templateId,
      'name': name,
      'discoveredSpotId': discoveredSpotId,
      'discoveredSpotName': discoveredSpotName,
      'discoveredAddr': discoveredAddr,
      'discoveredAt': discoveredAt, // Firestore Timestamp 자동 변환 처리(설정/환경에 따라)
      'stepsAtDiscovery': stepsAtDiscovery,
      'currentTotalSteps': currentTotalSteps,
      'isHatched': isHatched,
      'grade': grade,
    };
  }
}
