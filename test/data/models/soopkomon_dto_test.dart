import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soopkomong/data/models/soopkomon_dto.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';

void main() {
  group('SoopkomonDto', () {
    final now = DateTime.now();

    test('should map from Firestore Map correctly when discoveredAt is Timestamp', () {
      final map = {
        'templateId': '001',
        'name': '테스트몽',
        'discoveredSpotId': 'spot123',
        'discoveredSpotName': '어린이대공원',
        'discoveredAddr': '서울시 광진구',
        'discoveredAt': Timestamp.fromDate(now),
        'stepsAtDiscovery': 5000,
        'currentTotalSteps': 6000,
        'isHatched': false,
        'grade': 'A',
      };

      final dto = SoopkomonDto.fromMap(map, 'instance_123');

      expect(dto.instanceId, 'instance_123');
      expect(dto.templateId, '001');
      expect(dto.name, '테스트몽');
      // Timestamp.fromDate drops microsecond precision, so compare up to milliseconds
      expect(dto.discoveredAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch ~/ 1000 * 1000 + (now.millisecondsSinceEpoch % 1000));
      expect(dto.stepsAtDiscovery, 5000);
      expect(dto.isHatched, false);
      expect(dto.grade, 'A');
    });

    test('should map from Firestore Map correctly when discoveredAt is String ISO8601', () {
      final map = {
        'templateId': '002',
        'name': '스트링몽',
        'discoveredAt': now.toIso8601String(),
        'stepsAtDiscovery': 1000,
      };

      final dto = SoopkomonDto.fromMap(map, 'instance_456');

      expect(dto.instanceId, 'instance_456');
      expect(dto.templateId, '002');
      expect(dto.name, '스트링몽');
      expect(dto.discoveredAt.year, now.year);
      expect(dto.stepsAtDiscovery, 1000);
      expect(dto.grade, 'C'); // default fallback
    });

    test('should map toMap correctly', () {
      final entity = Soopkomon(
        instanceId: 'inst999',
        templateId: '003',
        name: '내칭구',
        discoveredSpotId: 'spot999',
        discoveredSpotName: '공원',
        discoveredAddr: '주소',
        discoveredAt: now,
        stepsAtDiscovery: 100,
        currentTotalSteps: 200,
        isHatched: true,
        grade: 'S',
      );

      final dto = SoopkomonDto.fromEntity(entity);
      final map = dto.toMap();

      expect(map['templateId'], '003');
      expect(map['name'], '내칭구');
      expect(map['discoveredAt'], now); // Not converted to Timestamp yet, handled by setup
      expect(map['stepsAtDiscovery'], 100);
      expect(map['currentTotalSteps'], 200);
      expect(map['isHatched'], true);
      expect(map['grade'], 'S');
    });
  });
}
