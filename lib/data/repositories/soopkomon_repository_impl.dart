import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
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
    final String response = await rootBundle.loadString('assets/templates.json');
    final List<dynamic> templatesJson = json.decode(response) as List<dynamic>;
    return templatesJson
        .map((json) => SoopkomonTemplateModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Location>> getLocations({AppLocale locale = AppLocale.ko}) async {
    // 1. 먼저 Firestore에서 데이터를 시도합니다.
    try {
      final remoteLocations = await _remoteDataSource.getRemoteLocations(locale: locale);
      if (remoteLocations.isNotEmpty) {
        return remoteLocations;
      }
    } catch (e) {
      print('Firestore 데이터 로드 실패 ($locale), 로컬 데이터를 사용합니다: $e');
    }

    // 2. 리모트 데이터가 없으면 로컬 에셋 로드 및 병합
    final String response = await rootBundle.loadString('assets/locations.json');
    final Map<String, dynamic> data = json.decode(response);
    final List<dynamic> localJsonList = data['locations'] ?? [];

    if (locale == AppLocale.en) {
      try {
        final String enResponse = await rootBundle.loadString('assets/en_locations.json');
        final List<dynamic> enJsonList = json.decode(enResponse);

        final Map<int, Map<String, dynamic>> enMap = {
          for (var item in enJsonList)
            (item['id'] as int): item as Map<String, dynamic>,
        };

        final mergedJsonList = localJsonList.map((locJson) {
          final Map<String, dynamic> loc = Map<String, dynamic>.from(locJson as Map<String, dynamic>);
          final int id = loc['id'] as int;

          if (enMap.containsKey(id)) {
            final enData = enMap[id]!;
            loc['title'] = enData['title'];
            loc['summary'] = enData['summary'];
            loc['Information'] = enData['information'] ?? enData['Information'] ?? loc['Information'];
          }
          return loc;
        }).toList();

        return mergedJsonList.map((json) => LocationModel.fromJson(json)).toList();
      } catch (e) {
        print('로컬 영어 데이터 병합 실패: $e');
      }
    }

    return localJsonList.map((json) => LocationModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<String>> getParkTitlesByPetId(String petId) async {
    final locations = await getLocations();
    final uniqueMap = <int, Location>{};
    for (var loc in locations) {
      uniqueMap[loc.id] = loc;
    }
    return uniqueMap.values
        .where((loc) => loc.petIds.contains(petId))
        .map((loc) => loc.name)
        .toList();
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
