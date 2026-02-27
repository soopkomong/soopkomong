import 'dart:math' as math;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// [Core Layer] - Utility (Geospatial Computations)
/// 지리 정보를 다루기 위해(예: n 미터 반경 원 폴리곤 좌표 계산) 수학적 계산을 수행하는 유틸리티입니다.
/// 특정 화면이나 비즈니스 기능에 종속되지 않고 어디서든 재사용 가능한 함수 단위로 제공됩니다.
List<Position> createCircleCoordinates(
  Position center,
  double radiusInMeters, {
  int steps = 64,
}) {
  final List<Position> coordinates = [];
  const double earthRadius = 6378137.0; // Earth's radius in meters

  final double centerLatRad = center.lat * math.pi / 180.0;
  final double centerLngRad = center.lng * math.pi / 180.0;
  final double d = radiusInMeters / earthRadius; // angular distance in radians

  for (int i = 0; i <= steps; i++) {
    final double bearing = i * 2 * math.pi / steps;

    final double latRad = math.asin(
      math.sin(centerLatRad) * math.cos(d) +
          math.cos(centerLatRad) * math.sin(d) * math.cos(bearing),
    );

    final double lngRad =
        centerLngRad +
        math.atan2(
          math.sin(bearing) * math.sin(d) * math.cos(centerLatRad),
          math.cos(d) - math.sin(centerLatRad) * math.sin(latRad),
        );

    final double lat = latRad * 180.0 / math.pi;
    final double lng = lngRad * 180.0 / math.pi;

    coordinates.add(Position(lng, lat));
  }

  return coordinates;
}
