import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class FirestoreUploader {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> uploadAllData() async {
    try {
      debugPrint('🚀 Firestore Upload Started...');
      
      // 1. locations.json -> locations
      await _uploadCollection(
        assetPath: 'assets/locations.json',
        collectionName: 'locations',
        idField: 'id',
        isLocationsRoot: true,
      );

      // 2. en_locations.json -> locations_en
      await _uploadCollection(
        assetPath: 'assets/en_locations.json',
        collectionName: 'locations_en',
        idField: 'id',
      );

      // 3. templates.json -> templates
      await _uploadCollection(
        assetPath: 'assets/templates.json',
        collectionName: 'templates',
        idField: 'templateId',
      );

      // 4. en_templates.json -> templates_en
      await _uploadCollection(
        assetPath: 'assets/en_templates.json',
        collectionName: 'templates_en',
        idField: 'templateId',
      );

      debugPrint('✅ All data uploaded successfully!');
    } catch (e) {
      debugPrint('❌ Failed to upload data: $e');
      rethrow;
    }
  }

  static Future<void> _uploadCollection({
    required String assetPath,
    required String collectionName,
    required String idField,
    bool isLocationsRoot = false,
  }) async {
    debugPrint('Reading $assetPath...');
    final String response = await rootBundle.loadString(assetPath);
    final dynamic decodedData = json.decode(response);
    
    List<dynamic> items;
    if (isLocationsRoot) {
      items = decodedData['locations'] as List<dynamic>;
    } else {
      items = decodedData as List<dynamic>;
    }

    debugPrint('Uploading ${items.length} items to $collectionName...');
    
    // Firestore Batch 사용 (최대 500개)
    WriteBatch batch = _db.batch();
    int count = 0;

    for (var item in items) {
      final docId = item[idField].toString();
      final docRef = _db.collection(collectionName).doc(docId);
      
      batch.set(docRef, item as Map<String, dynamic>);
      count++;

      if (count % 500 == 0) {
        await batch.commit();
        batch = _db.batch();
        debugPrint('  $count items committed...');
      }
    }

    await batch.commit();
    debugPrint('Done! Uploaded $count items to $collectionName.');
  }
}
