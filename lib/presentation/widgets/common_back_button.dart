import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

class CommonBackButton extends StatelessWidget {
  const CommonBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.gray100,
    this.iconColor = AppColors.black,
    this.iconData = Icons.arrow_back_ios_new,
    this.size = 40.0,
    this.iconSize = 18.0,
  });

  /// 버튼 클릭 시의 동작. 기본값은 context.pop()입니다.
  final VoidCallback? onPressed;

  /// 배경색
  final Color backgroundColor;

  /// 테두리 색상
  final Color borderColor;

  /// 아이콘 색상
  final Color iconColor;

  /// 표시할 아이콘 데이터
  final IconData iconData;

  /// 버튼의 전체 크기 (지름)
  final double size;

  /// 내부 아이콘의 크기
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            iconData,
            color: iconColor,
            size: iconSize,
          ),
          onPressed: onPressed ?? () => context.pop(),
        ),
      ),
    );
  }
}
