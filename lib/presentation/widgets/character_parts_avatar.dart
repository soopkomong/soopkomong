import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

/// 캐릭터 파츠를 실시간으로 조합하여 렌더링하는 위젯
class CharacterPartsAvatar extends StatelessWidget {
  final Map<String, dynamic>? settings;
  final String baseImagePath;
  final String? bodyShadowImagePath;
  final Color baseColor;
  final String clothesImagePath;
  final Color clothesColor;
  final String? shoesImagePath;
  final Color shoesColor;
  final String faceImagePath;
  final String hairImagePath;
  final String? hairSubShadowImagePath;
  final String? hairShadowImagePath;
  final String? hairHighlightImagePath;
  final Color hairColor;
  final double size;

  CharacterPartsAvatar({
    super.key,
    this.settings,
    String? baseImagePath,
    String? bodyShadowImagePath,
    Color? baseColor,
    String? clothesImagePath,
    Color? clothesColor,
    String? shoesImagePath,
    Color? shoesColor,
    String? faceImagePath,
    String? hairImagePath,
    String? hairSubShadowImagePath,
    String? hairShadowImagePath,
    String? hairHighlightImagePath,
    Color? hairColor,
    required this.size,
  }) : baseImagePath = baseImagePath ?? 'body_base.png',
       bodyShadowImagePath =
           bodyShadowImagePath ?? (settings != null ? 'body_shadow.png' : null),
       baseColor =
           baseColor ??
           (settings != null && settings['skinColor'] != null
               ? Color((settings['skinColor'] as num).toInt())
               : Colors.white),
       hairImagePath =
           hairImagePath ??
           (settings != null && settings['hair'] != null
               ? 'hair_${settings['hair']}.png'
               : 'hair_01.png'),
       hairShadowImagePath =
           hairShadowImagePath ??
           (settings != null && settings['hair'] != null
               ? 'hair_${settings['hair']}_shadow.png'
               : null),
       hairSubShadowImagePath =
           hairSubShadowImagePath ??
           (settings != null && settings['hair'] != null
               ? 'hair_${settings['hair']}_sub_shadow.png'
               : null),
       hairHighlightImagePath =
           hairHighlightImagePath ??
           (settings != null && settings['hair'] != null
               ? 'hair_${settings['hair']}_highlight.png'
               : null),
       hairColor =
           hairColor ??
           (settings != null && settings['hairColor'] != null
               ? Color((settings['hairColor'] as num).toInt())
               : const Color(0xFF6D4C41)),
       faceImagePath =
           faceImagePath ??
           (settings != null && settings['face'] != null
               ? 'face_${settings['face']}.png'
               : 'face_smile.png'),
       clothesImagePath =
           clothesImagePath ??
           (settings != null && settings['clothes'] != null
               ? 'clothes_${settings['clothes']}.png'
               : 'clothes_01.png'),
       clothesColor =
           clothesColor ??
           (settings != null && settings['clothesColor'] != null
               ? Color((settings['clothesColor'] as num).toInt())
               : Colors.white),
       shoesImagePath =
           shoesImagePath ??
           (settings != null && settings['shoes'] != null
               ? 'shoes_${settings['shoes']}.png'
               : null),
       shoesColor =
           shoesColor ??
           (settings != null && settings['shoesColor'] != null
               ? Color((settings['shoesColor'] as num).toInt())
               : AppColors.white);

  static const _storageBaseUrl =
      'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/';

  String _getPartUrl(String assetPath) {
    final fileName = assetPath.split('/').last;
    if (assetPath.contains('/thumbnails/')) {
      return '${_storageBaseUrl}parts%2Fthumbnails%2F$fileName?alt=media';
    }
    return '${_storageBaseUrl}parts%2F$fileName?alt=media';
  }

  Widget _buildPartImage({
    required String? path,
    Color? color,
    BlendMode colorBlendMode = BlendMode.modulate,
    double? opacity,
  }) {
    if (path == null || path.isEmpty) return const SizedBox.shrink();

    final imageUrl = _getPartUrl(path);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: colorBlendMode,
      memCacheWidth: (size * 2).toInt(),
      memCacheHeight: (size * 2).toInt(),
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        color: AppColors.white.withValues(alpha: 0.1),
      ),
      errorWidget: (context, url, error) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildPartImage(path: baseImagePath, color: baseColor),
          if (bodyShadowImagePath != null)
            _buildPartImage(
              path: bodyShadowImagePath!,
              color: const Color(0xFF6D4C41).withValues(alpha: 0.3),
            ),
          _buildPartImage(path: faceImagePath),
          if (hairSubShadowImagePath != null)
            _buildPartImage(
              path: hairSubShadowImagePath!,
              color: const Color(0xFF6D4C41).withValues(alpha: 0.3),
            ),
          _buildPartImage(path: hairImagePath, color: hairColor),
          if (hairShadowImagePath != null)
            _buildPartImage(
              path: hairShadowImagePath!,
              color: const Color(0xFF263238).withValues(alpha: 0.25),
            ),
          if (hairHighlightImagePath != null)
            _buildPartImage(path: hairHighlightImagePath!, opacity: 0.7),
          if (shoesImagePath != null) _buildPartImage(path: shoesImagePath!),
          _buildPartImage(path: clothesImagePath),
        ],
      ),
    );
  }
}
