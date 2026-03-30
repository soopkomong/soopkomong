import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class AppToast {
  static final FToast _fToast = FToast();

  static void show(BuildContext context, String message) {
    // 사용자의 요청에 따라 iOS 플랫폼에서만 알림을 표시함
    if (!Platform.isIOS) return;

    _fToast.init(context);
    _fToast.removeCustomToast(); // 기존 토스트가 있다면 제거

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.gray800.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message,
        style: AppTextStyles.subTitleM.copyWith(
          color: AppColors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) {
        return Positioned(
          bottom: 100.0, // 바텀시트 위쪽 적절한 위치에 표시되도록 설정
          left: 20.0,
          right: 20.0,
          child: child,
        );
      },
    );
  }
}
