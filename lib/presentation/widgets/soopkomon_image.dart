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
          if (onLoaded != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => onLoaded?.call(),
            );
          }
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
          if (onLoaded != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => onLoaded?.call(),
            );
          }
          return errorWidget ??
              Image.asset(
                assetPath,
                width: width,
                height: height,
                fit: fit,
                color: color,
                colorBlendMode: colorBlendMode,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/character_silhouette.png',
                  width: width,
                  height: height,
                  fit: fit,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
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
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          if (onLoaded != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => onLoaded?.call(),
            );
          }
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        if (onLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onLoaded?.call());
        }
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
