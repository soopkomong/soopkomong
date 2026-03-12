import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soopkomong/data/models/soopkomon_template_model.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';

/// 로컬 에셋(JSON) 기반의 리포지토리 구현체
class SoopkomonRepositoryImpl implements SoopkomonRepository {
  @override
  Future<List<SoopkomonTemplate>> getSoopkomonTemplates() async {
    final String response = await rootBundle.loadString(
      'assets/templates.json',
    );
    final List<dynamic> templatesJson = json.decode(response) as List<dynamic>;

    return templatesJson
        .map((json) => SoopkomonTemplateModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<dynamic>> getLocations() async {
    final String response = await rootBundle.loadString(
      'assets/locations.json',
    );
    final data = json.decode(response);
    return data['locations'] ?? [];
  }
}
