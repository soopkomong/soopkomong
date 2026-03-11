import 'package:flutter/material.dart';

class AppTextStyles {
  static const String _fontFamily = 'Pretendard';

  // Headline: Pretendard / SemiBold / 24
  static const TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  // Title: Pretendard / SemiBold / 20
  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  // Sub Title/ L: Pretendard / SemiBold / 16
  static const TextStyle subTitleL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  // Sub Title/ M: Pretendard / SemiBold / 14
  static const TextStyle subTitleM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  // Body: Pretendard / Regular / 14
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
  );

  // Label: Pretendard / Medium / 12
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
  );
}
