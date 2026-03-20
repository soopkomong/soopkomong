import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soopkomong/data/datasources/remote_location_datasource.dart';
import 'package:soopkomong/data/models/location_model.dart';
import 'package:soopkomong/data/models/soopkomon_template_model.dart';
import 'package:soopkomong/domain/entities/location.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/domain/repositories/soopkomon_repository.dart';

/// Firestore와 로컬 에셋(JSON)을 결합한 리포지토리 구현체
class SoopkomonRepositoryImpl implements SoopkomonRepository {
  final RemoteLocationDataSource _remoteDataSource;

  SoopkomonRepositoryImpl({required RemoteLocationDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SoopkomonTemplate>> getSoopkomonTemplates() async {
    // 로컬 에셋을 즉시 로드 (빠른 초기 렌더링)
    final String response = await rootBundle.loadString('assets/templates.json');
    final List<dynamic> templatesJson = json.decode(response) as List<dynamic>;
    return templatesJson
        .map((json) => SoopkomonTemplateModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Location>> getLocations() async {
    // 로컬 에셋을 즉시 로드 (빠른 초기 렌더링)
    final String response = await rootBundle.loadString('assets/locations.json');
    final data = json.decode(response);
    final List<dynamic> locationsJson = data['locations'] ?? [];
    return locationsJson.map((json) => LocationModel.fromJson(json)).toList();
  }

  @override
  Stream<List<Soopkomon>> getUserSoopkomons(String userId) {
    return _remoteDataSource.firestore
        .collection('users')
        .doc(userId)
        .collection('acquired_soopkomons')
        .orderBy('discoveredAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Soopkomon.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> addSoopkomon(String userId, Soopkomon soopkomon) async {
    await _remoteDataSource.firestore
        .collection('users')
        .doc(userId)
        .collection('acquired_soopkomons')
        .doc(soopkomon.instanceId)
        .set(soopkomon.toMap());
  }

  @override
  Future<void> updateSoopkomonSteps(
    String userId,
    String instanceId,
    int steps,
  ) async {
    await _remoteDataSource.firestore
        .collection('users')
        .doc(userId)
        .collection('acquired_soopkomons')
        .doc(instanceId)
        .update({'currentTotalSteps': steps});
  }

  @override
  Future<void> markSoopkomonAsHatched(String userId, String instanceId) async {
    await _remoteDataSource.firestore
        .collection('users')
        .doc(userId)
        .collection('acquired_soopkomons')
        .doc(instanceId)
        .update({'isHatched': true});
  }
}
