import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray100,
      highlightColor: AppColors.gray50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ParkCardSkeleton extends StatelessWidget {
  const ParkCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerLoading(width: double.infinity, height: 117, borderRadius: 12),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerLoading(width: 100, height: 16),
              const SizedBox(height: 4),
              const ShimmerLoading(width: 60, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class SoopkomongCardSkeleton extends StatelessWidget {
  const SoopkomongCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AspectRatio(
          aspectRatio: 1.0,
          child: ShimmerLoading(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 24,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(width: 40, height: 14),
              SizedBox(height: 4),
              ShimmerLoading(width: 80, height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
