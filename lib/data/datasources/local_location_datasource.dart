import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soopkomong/data/models/pet_location_model.dart';

/// [Data Layer] - DataSource Interface
/// 로컬 자원(Asset JSON)이나 외부 API 등으로부터 원시 데이터를 가져오는 규격을 정의합니다.
abstract class LocalLocationDataSource {
  Future<List<PetLocationModel>> getLocalLocations();
}

class LocalLocationDataSourceImpl implements LocalLocationDataSource {
  @override
  Future<List<PetLocationModel>> getLocalLocations() async {
    final jsonString = await rootBundle.loadString('assets/locations.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final List<dynamic> locationsData = jsonData['locations'] ?? [];

    return locationsData
        .map((data) => PetLocationModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}
