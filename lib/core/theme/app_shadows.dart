import 'package:flutter/material.dart';

class AppShadows {
  /// 매우 가벼운 그림자 (소형 위젯)
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x14000000), // 8% Black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// 기본 카드 그림자 (InfoCard, StepCountCard 등)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x26000000), // 15% Black
      blurRadius: 4,
      offset: Offset(0, 0),
    ),
  ];

  /// 하단 바 등 떠 있는 느낌의 위젯용 그림자
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x3F000000), // 25% Black
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  /// 다이얼로그 및 바텀 시트용 강한 그림자
  static const List<BoxShadow> strong = [
    BoxShadow(
      color: Color(0x40000000), // 25% Black
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}
