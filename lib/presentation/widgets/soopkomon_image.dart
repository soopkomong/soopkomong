import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/widgets/shimmer_loading.dart';

class SoopkomonImage extends StatelessWidget {
  final String assetPath;
  final String? remoteUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget? errorWidget;
  final VoidCallback? onLoaded;

  const SoopkomonImage({
    super.key,
    required this.assetPath,
    this.remoteUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode,
    this.errorWidget,
    this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    // remoteUrl이 있는 경우에만 네트워크 이미지 사용
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: remoteUrl!,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        fadeOutDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        placeholder: (context, url) => const ShimmerLoading(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 0,
        ),
        imageBuilder: (context, imageProvider) {
          // 루프 방지를 위해 콜백 제거 또는 가드 필요. 여기선 일단 제거.
          return Image(
            image: imageProvider,
            width: width,
            height: height,
            fit: fit,
            color: color,
            colorBlendMode: colorBlendMode,
          );
        },
        errorWidget: (context, url, error) {
          return errorWidget ??
              Image.asset(
                'assets/images/character_silhouette.png',
                width: width,
                height: height,
                fit: fit,
                color: Colors.grey.withValues(alpha: 0.5),
              );
        },
      );
    }

    // remoteUrl이 없으면 로컬 에셋 사용
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Image.asset(
              'assets/images/character_silhouette.png',
              width: width,
              height: height,
              fit: fit,
              color: Colors.grey.withValues(alpha: 0.5),
            );
      },
    );
  }
}
