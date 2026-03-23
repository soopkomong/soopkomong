import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CharacterAvatar extends StatelessWidget {
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

  CharacterAvatar({
    super.key,
    Map<String, dynamic>? settings,
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
    this.size = 250.0,
  })  : baseImagePath = baseImagePath ?? 'body_base.png',
        baseColor =
            baseColor ??
            (settings != null
                ? Color(settings['skinColor'] as int)
                : Colors.white),
        hairImagePath =
            hairImagePath ??
            (settings != null ? 'hair_${settings['hair']}.png' : 'hair_01.png'),
        hairHighlightImagePath = hairHighlightImagePath ??
            (settings != null ? 'hair_${settings['hair']}_highlight.png' : null),
        hairColor =
            hairColor ??
            (settings != null
                ? Color(settings['hairColor'] as int)
                : Colors.white),
        faceImagePath = faceImagePath ??
            (settings != null ? 'face_${settings['face']}.png' : 'face_smile.png'),
        clothesImagePath = clothesImagePath ??
            (settings != null
                ? 'clothes_${settings['clothes']}.png'
                : 'clothes_01.png'),
        clothesColor =
            clothesColor ??
            (settings != null
                ? Color(settings['clothesColor'] as int)
                : Colors.white),
        shoesImagePath = shoesImagePath ??
            (settings != null && settings['shoes'] != null
                ? 'shoes_${settings['shoes']}.png'
                : null),
        shoesColor =
            shoesColor ??
            (settings != null
                ? Color(settings['shoesColor'] as int? ?? 0xFFFFFFFF)
                : Colors.white);

  /// characterSettings 맵을 받아 CharacterAvatar를 생성하는 팩토리 생성자 (하위 호환 유지)
  factory CharacterAvatar.fromSettings(
    Map<String, dynamic> settings, {
    double size = 250.0,
  }) {
    return CharacterAvatar(settings: settings, size: size);
  }

  // Firebase Storage 다운로드 URL 조성을 위한 기본 URL
  static const _storageBaseUrl = 'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/';

  /// 에셋 경로를 Firebase Storage URL로 변환
  /// [fileName] 형식: body_base.png, hair_01.png 등 (parts/ 폴더 내 파일명)
  /// [output] 형식: https://firebasestorage.googleapis.com/v0/b/.../o/parts%2Fbody_base.png?alt=media
  String _getPartUrl(String assetPath) {
    final fileName = assetPath.split('/').last;
    // 썸네일 폴더에 있는 경우 처리
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
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: size,
          height: size,
          color: Colors.white,
        ),
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
          // 1. 몸통 (제일 아래 - 피부색 적용)
          _buildPartImage(path: baseImagePath, color: baseColor),

          // 1.5. 몸 그림자 (피부 위 전체적인 그림자)
          if (bodyShadowImagePath != null)
            _buildPartImage(
              path: bodyShadowImagePath!,
              color: const Color(0xFF6D4C41).withValues(alpha: 0.3),
            ),

          // 4. 얼굴(표정)
          _buildPartImage(path: faceImagePath),

          // 4.5. 머리 밑 그림자
          if (hairSubShadowImagePath != null)
            _buildPartImage(
              path: hairSubShadowImagePath!,
              color: const Color(0xFF6D4C41).withValues(alpha: 0.3),
            ),

          // 5. 머리 본체
          _buildPartImage(path: hairImagePath, color: hairColor),

          // 5.5. 머리 그림자
          if (hairShadowImagePath != null)
            _buildPartImage(
              path: hairShadowImagePath!,
              color: const Color(0xFF263238).withValues(alpha: 0.25),
            ),

          // 6. 머리 하이라이트
          if (hairHighlightImagePath != null)
            _buildPartImage(path: hairHighlightImagePath!, opacity: 0.7),

          // 2. 신발
          if (shoesImagePath != null)
            _buildPartImage(path: shoesImagePath!, color: shoesColor),

          // 3. 옷
          _buildPartImage(path: clothesImagePath, color: clothesColor),
        ],
      ),
    );
  }
}

/// AppUser 데이터를 바탕으로 아바타를 간편하게 표시해주는 위젯
class UserAvatar extends StatelessWidget {
  final Map<String, dynamic>? characterSettings;
  final String? photoUrl;
  final double size;
  final bool isProfileMode;

  const UserAvatar({
    super.key,
    this.characterSettings,
    this.photoUrl,
    this.size = 80,
    this.isProfileMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 이미 저장된 프로필 사진 URL(photoUrl)이 있다면 최우선으로 표시
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
          imageUrl: photoUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 이미지 로드 실패 시 아바타 파츠로 폴백(Fallback)
          errorWidget: (context, url, error) => _buildAvatarFromSettings(),
        ),
        ),
      );
    }

    // 2. 사진 URL이 없으면 아바타 설정값으로 실시간 렌더링
    return _buildAvatarFromSettings();
  }

  Widget _buildAvatarFromSettings() {
    if (characterSettings != null) {
      Widget avatar = CharacterAvatar(settings: characterSettings, size: size);

      // 프로필 모드일 경우 얼굴 위주로 확대해서 보여줌
      if (isProfileMode) {
        return ClipOval(
          child: Transform.translate(
            offset: Offset(0, size * 0.40), // 배율 축소에 맞춰 위치 살짝 상향 조정
            child: Transform.scale(
              scale: 1.8, // 2.2에서 1.8로 축소하여 여유 공간 확보
              child: avatar,
            ),
          ),
        );
      }
      return avatar;
    }

    // 3. 둘 다 없으면 기본 아이콘 표시
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Center(
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
