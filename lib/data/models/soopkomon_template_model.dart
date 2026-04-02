import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/domain/entities/soopkomon_enums.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';

class SoopkomonTemplateModel extends SoopkomonTemplate {
  SoopkomonTemplateModel({
    required super.templateId,
    required super.grade,
    required super.name,
    required super.description,
    required super.eggType,
    required super.region,
  });

  factory SoopkomonTemplateModel.fromJson(Map<String, dynamic> json) {
    return SoopkomonTemplateModel(
      templateId: json['templateId'] as String? ?? '',
      grade: json['grade'] as String? ?? 'C',
      name: json['name'] as String? ?? '알 수 없음',
      description: json['description'] as String? ?? '',
      eggType: SoopkomonEggType.fromValue(
        json['eggType'] as String? ?? 'mystery',
      ),
      region: Region.fromValue(json['region'] as String? ?? 'capital'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'grade': grade,
      'name': name,
      'description': description,
      'eggType': eggType.name,
      'region': region.name,
    };
  }

  SoopkomonTemplate toEntity() {
    return SoopkomonTemplate(
      templateId: templateId,
      grade: grade,
      name: name,
      description: description,
      eggType: eggType,
      region: region,
    );
  }
}
