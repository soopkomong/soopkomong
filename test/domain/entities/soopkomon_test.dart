import 'package:flutter_test/flutter_test.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';

// 숲코몽 캐릭터 엔티티가 데이터 흐름대로 오류 없이 돌아가는지 확인하는 테스트
// 걸음 수 계산, 상태 업데이트, 이미지 경로 추출

void main() {
  group('Soopkomon Entity Tests', () {
    final now = DateTime.now();

    test('traveledSteps should calculate correctly', () {
      final pet = Soopkomon(
        instanceId: '1',
        templateId: '001',
        name: '초록이',
        discoveredSpotId: 'park1',
        discoveredSpotName: '성수동 공원',
        discoveredAddr: '서울시 성수동',
        discoveredAt: now,
        stepsAtDiscovery: 5000,
        currentTotalSteps: 5500,
        isHatched: false,
      );

      expect(pet.traveledSteps, 500);
    });

    test('copyWith should update fields correctly', () {
      final pet = Soopkomon(
        instanceId: '1',
        templateId: '001',
        name: '초록이',
        discoveredSpotId: 'park1',
        discoveredSpotName: '성수동 공원',
        discoveredAddr: '서울시 성수동',
        discoveredAt: now,
        stepsAtDiscovery: 5000,
        currentTotalSteps: 5000,
        isHatched: false,
      );

      final hatchedPet = pet.copyWith(isHatched: true, currentTotalSteps: 6000);

      expect(hatchedPet.isHatched, true);
      expect(hatchedPet.currentTotalSteps, 6000);
      expect(hatchedPet.traveledSteps, 1000);
      expect(pet.isHatched, false);
    });

    test('imagePath should return correct asset path', () {
      final pet = Soopkomon(
        instanceId: '1',
        templateId: '007',
        name: '물꼬몽',
        discoveredSpotId: 'park1',
        discoveredSpotName: '성수동 공원',
        discoveredAddr: '서울시 성수동',
        discoveredAt: now,
        stepsAtDiscovery: 5000,
        isHatched: true,
      );

      expect(pet.imagePath, 'assets/images/characters/007_big.png');
    });
  });
}
