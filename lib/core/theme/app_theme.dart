import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary500,
        primary: AppColors.primary500,
        secondary: AppColors.orange,
        surface: Colors.white,
      ),

      // AppBar 전역 테마
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.subTitleL.copyWith(
          color: AppColors.gray900,
        ),
        iconTheme: IconThemeData(color: AppColors.gray900),
      ),

      // 입력창(TextField) 전역 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray400, width: 1.5),
        ),
      ),

      // 인디케이터 (게이지) 전역 테마
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary600,
        linearTrackColor: AppColors.gray100,
        circularTrackColor: AppColors.gray100,
        refreshBackgroundColor: Colors.white,
      ),
    );
  }
}
