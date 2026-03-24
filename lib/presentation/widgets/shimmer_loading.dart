import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder? shapeBorder;
  final double? borderRadius;

  // 기존 코드(borderRadius 사용)와 호환되는 기본 생성자
  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.shapeBorder,
  });

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.borderRadius,
  });

  const ShimmerLoading.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: AppColors.gray300,
          shape: shapeBorder ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12),
              ),
        ),
      ),
    );
  }
}
