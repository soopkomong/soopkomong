import 'package:soopkomong/domain/entities/soopkomon.dart';

class SoopkomonModel extends Soopkomon {
  SoopkomonModel({
    required super.instanceId,
    required super.templateId,
    required super.name,
    required super.discoveredSpotId,
    required super.discoveredSpotName,
    required super.discoveredAddr,
    required super.discoveredAt,
    required super.stepsAtDiscovery,
    super.currentTotalSteps = 0,
  });

  factory SoopkomonModel.fromJson(Map<String, dynamic> json) {
    return SoopkomonModel(
      instanceId: json['instanceId'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      name: json['name'] as String? ?? '알 수 없음',
      discoveredSpotId: json['discoveredSpotId'] as String? ?? '',
      discoveredSpotName: json['discoveredSpotName'] as String? ?? '',
      discoveredAddr: json['discoveredAddr'] as String? ?? '',
      discoveredAt: DateTime.parse(json['discoveredAt'] as String? ?? DateTime.now().toIso8601String()),
      stepsAtDiscovery: json['stepsAtDiscovery'] as int? ?? 0,
      currentTotalSteps: json['currentTotalSteps'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instanceId': instanceId,
      'templateId': templateId,
      'name': name,
      'discoveredSpotId': discoveredSpotId,
      'discoveredSpotName': discoveredSpotName,
      'discoveredAddr': discoveredAddr,
      'discoveredAt': discoveredAt.toIso8601String(),
      'stepsAtDiscovery': stepsAtDiscovery,
      'currentTotalSteps': currentTotalSteps,
    };
  }

  Soopkomon toEntity() {
    return Soopkomon(
      instanceId: instanceId,
      templateId: templateId,
      name: name,
      discoveredSpotId: discoveredSpotId,
      discoveredSpotName: discoveredSpotName,
      discoveredAddr: discoveredAddr,
      discoveredAt: discoveredAt,
      stepsAtDiscovery: stepsAtDiscovery,
      currentTotalSteps: currentTotalSteps,
    );
  }
}
