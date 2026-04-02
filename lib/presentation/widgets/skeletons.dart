import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/shimmer_loading.dart';

class ParkCardSkeleton extends StatelessWidget {
  const ParkCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerLoading.rectangular(height: 98), // 130 / 1.33
          SizedBox(height: 10),
          ShimmerLoading.rectangular(height: 16, width: 100),
          SizedBox(height: 4),
          ShimmerLoading.rectangular(height: 14, width: 60),
        ],
      ),
    );
  }
}

class SoopkomongCardSkeleton extends StatelessWidget {
  const SoopkomongCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        ShimmerLoading.rectangular(width: 86, height: 86),
        SizedBox(height: 8),
        ShimmerLoading.rectangular(width: 80, height: 16),
      ],
    );
  }
}
