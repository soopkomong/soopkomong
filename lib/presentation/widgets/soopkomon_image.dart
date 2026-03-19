import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SoopkomonImage extends StatelessWidget {
  final String assetPath;
  final String remoteUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget? errorWidget;

  const SoopkomonImage({
    super.key,
    required this.assetPath,
    required this.remoteUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 이제 로컬 에셋은 사용하지 않으므로 CachedNetworkImage를 기본으로 사용합니다.
    return CachedNetworkImage(
      imageUrl: remoteUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Image.asset(
            'assets/images/character_silhouette.png',
            width: width,
            height: height,
            fit: fit,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
    );
  }
}
