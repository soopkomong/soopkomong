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
    this.bodyShadowImagePath,
    Color? baseColor,
    String? clothesImagePath,
    Color? clothesColor,
    String? shoesImagePath,
    Color? shoesColor,
    String? faceImagePath,
    String? hairImagePath,
    this.hairSubShadowImagePath,
    this.hairShadowImagePath,
    String? hairHighlightImagePath,
    Color? hairColor,
    required this.size,
  }) : baseImagePath = baseImagePath ?? 'body_base.png',
       baseColor =
           baseColor ??
           (settings != null
               ? Color(settings['skinColor'] as int)
               : Colors.white),
       hairImagePath =
           hairImagePath ??
           (settings != null ? 'hair_${settings['hair']}.png' : 'hair_01.png'),
       hairHighlightImagePath =
           hairHighlightImagePath ??
           (settings != null ? 'hair_${settings['hair']}_highlight.png' : null),
       hairColor =
           hairColor ??
           (settings != null
               ? Color(settings['hairColor'] as int)
               : Colors.white),
       faceImagePath =
           faceImagePath ??
           (settings != null
               ? 'face_${settings['face']}.png'
               : 'face_smile.png'),
       clothesImagePath =
           clothesImagePath ??
           (settings != null
               ? 'clothes_${settings['clothes']}.png'
               : 'clothes_01.png'),
       clothesColor =
           clothesColor ??
           (settings != null
               ? Color(settings['clothesColor'] as int)
               : Colors.white),
       shoesImagePath =
           shoesImagePath ??
           (settings != null && settings['shoes'] != null
               ? 'shoes_${settings['shoes']}.png'
               : null),
       shoesColor =
           shoesColor ??
           (settings != null
               ? Color(settings['shoesColor'] as int? ?? 0xFFFFFFFF)
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
    required String path,
    Color? color,
    BlendMode colorBlendMode = BlendMode.modulate,
    double? opacity,
  }) {
    final imageUrl = _getPartUrl(path);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: colorBlendMode,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (context, url) =>
          Container(width: size, height: size, color: AppColors.white.withValues(alpha: 0.1)),
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
