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
    this.size = 250.0,
  })  : baseImagePath =
            baseImagePath ??
            (settings != null
                ? 'assets/images/parts/body_base.png'
                : 'assets/images/parts/body_base.png'),
        bodyShadowImagePath = bodyShadowImagePath,
        baseColor =
            baseColor ??
            (settings != null
                ? Color(settings['skinColor'] as int)
                : Colors.white),
        hairImagePath =
            hairImagePath ??
            (settings != null
                ? 'assets/images/parts/hair_${settings['hair']}.png'
                : 'assets/images/parts/hair_01.png'),
        hairHighlightImagePath =
            hairHighlightImagePath ??
            (settings != null
                ? 'assets/images/parts/hair_${settings['hair']}_highlight.png'
                : null),
        hairShadowImagePath =
            hairShadowImagePath ??
            (settings != null
                ? 'assets/images/parts/hair_${settings['hair']}_shadow.png'
                : null),
        hairSubShadowImagePath =
            hairSubShadowImagePath ??
            (settings != null
                ? 'assets/images/parts/hair_${settings['hair']}_sub_shadow.png'
                : null),
        hairColor =
            hairColor ??
            (settings != null
                ? Color(settings['hairColor'] as int)
                : Colors.white),
        faceImagePath =
            faceImagePath ??
            (settings != null
                ? 'assets/images/parts/face_${settings['face']}.png'
                : 'assets/images/parts/face_smile.png'),
        clothesImagePath =
            clothesImagePath ??
            (settings != null
                ? 'assets/images/parts/clothes_${settings['clothes']}.png'
                : 'assets/images/parts/clothes_01.png'),
        clothesColor =
            clothesColor ??
            (settings != null
                ? Color(settings['clothesColor'] as int)
                : Colors.white),
        shoesImagePath =
            shoesImagePath ??
            (settings != null && settings['shoes'] != null
                ? 'assets/images/parts/shoes_${settings['shoes']}.png'
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 몸통 (제일 아래 - 피부색 적용)
          Image.asset(
            baseImagePath,
            width: size,
            height: size,
            color: baseColor,
            colorBlendMode: BlendMode.modulate,
          ),

          // 1.5. 몸 그림자 (피부 위 전체적인 그림자 - 탁하지 않게 따뜻한 갈색톤 그림자 사용)
          if (bodyShadowImagePath != null)
            Image.asset(
              bodyShadowImagePath!,
              width: size,
              height: size,
              color: const Color(
                0xFF6D4C41,
              ).withValues(alpha: 0.3), // 농도를 낮추고 따뜻한 톤 적용
              colorBlendMode: BlendMode.modulate,
            ),

          // 4. 얼굴(표정)
          Image.asset(faceImagePath, width: size, height: size),

          // 4.5. 머리 밑 그림자 (머리 본체 아래, 얼굴 위에 깔리는 그림자 - 맑은 느낌을 위해 농도 하향)
          if (hairSubShadowImagePath != null)
            Image.asset(
              hairSubShadowImagePath!,
              width: size,
              height: size,
              color: const Color(
                0xFF6D4C41,
              ).withOpacity(0.3), // 농도를 낮추고 따뜻한 톤 적용
              colorBlendMode: BlendMode.modulate,
            ),

          // 5. 머리 본체 (색상 및 블렌딩 직접 적용)
          Image.asset(
            hairImagePath,
            width: size,
            height: size,
            color: hairColor,
            colorBlendMode: BlendMode.modulate,
          ),

          // 5.5. 머리 그림자 (배경 침범 없이 캐릭터 영역에만 곱하기 효과 적용 - 농도 조절)
          if (hairShadowImagePath != null)
            Image.asset(
              hairShadowImagePath!,
              width: size,
              height: size,
              color: const Color(0xFF263238).withOpacity(0.25), // 농도를 낮추어 탁함 방지
              colorBlendMode: BlendMode.modulate, // 이미지 영역 내에서만 색상 혼합
            ),

          // 6. 머리 하이라이트 (존재할 경우에만 렌더링)
          if (hairHighlightImagePath != null)
            Opacity(
              opacity: 0.7, // 투명도 조절 (너무 강하지 않게)
              child: Image.asset(
                hairHighlightImagePath!,
                width: size,
                height: size,
              ),
            ),

          // 2. 신발 (선택 사항)
          if (shoesImagePath != null)
            Image.asset(
              shoesImagePath!,
              width: size,
              height: size,
              color: shoesColor,
              colorBlendMode: BlendMode.modulate,
            ),

          // 3. 옷
          Image.asset(
            clothesImagePath,
            width: size,
            height: size,
            color: clothesColor,
            colorBlendMode: BlendMode.modulate,
          ),
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
