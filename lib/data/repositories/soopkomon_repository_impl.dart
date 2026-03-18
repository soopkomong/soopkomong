import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soopkomong/data/datasources/remote_location_datasource.dart';
import 'package:soopkomong/data/models/location_model.dart';
import 'package:soopkomong/data/models/soopkomon_template_model.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';

/// Firestore와 로컬 에셋(JSON)을 결합한 리포지토리 구현체
class SoopkomonRepositoryImpl implements SoopkomonRepository {
  final RemoteLocationDataSource _remoteDataSource;

  SoopkomonRepositoryImpl({required RemoteLocationDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SoopkomonTemplate>> getSoopkomonTemplates() async {
    // 템플릿은 아직 로컬 유지 (필요시 Firestore 이전 가능)
    final String response = await rootBundle.loadString(
      'assets/templates.json',
    );
    final List<dynamic> templatesJson = json.decode(response) as List<dynamic>;

    return templatesJson
        .map((json) => SoopkomonTemplateModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Location>> getLocations() async {
    try {
      // 1. 먼저 Firestore에서 데이터를 시도합니다.
      final locations = await _remoteDataSource.getRemoteLocations();
      if (locations.isNotEmpty) {
        return locations;
      }
    } catch (e) {
      print('Firestore 데이터 로드 실패, 로컬 데이터를 사용합니다: $e');
    }

    // 2. 실패하거나 데이터가 없으면 로컬 에셋을 백업으로 사용합니다.
    final String response = await rootBundle.loadString(
      'assets/locations.json',
    );
    final data = json.decode(response);
    final List<dynamic> locationsJson = data['locations'] ?? [];
    return locationsJson.map((json) => LocationModel.fromJson(json)).toList();
  }
}
