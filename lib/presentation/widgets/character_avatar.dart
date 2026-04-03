import 'package:flutter/material.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'url_avatar.dart';
import 'character_parts_avatar.dart';

/// 메인 아바타 위젯 (매니저 역할)
/// 상황(photoUrl 여부, characterSettings 여부)에 따라 적절한 위젯을 반환합니다.
class CharacterAvatar extends StatelessWidget {
  final Map<String, dynamic>? characterSettings;
  final String? photoUrl;
  final String? templateId;
  final double size;
  final bool isProfileMode;
  final bool useCircle;
  final bool forceUrl;

  const CharacterAvatar({
    super.key,
    this.characterSettings,
    this.photoUrl,
    this.templateId,
    this.size = 100,
    this.isProfileMode = false,
    this.useCircle = false,
    this.forceUrl = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. forceUrl이 true이고 photoUrl이 있는 경우 우선 표시
    if (forceUrl && photoUrl != null && photoUrl!.isNotEmpty) {
      return UrlAvatar(photoUrl: photoUrl!, size: size, useCircle: useCircle);
    }

    // 2. 캐릭터 설정이 없고 URL이 있는 경우 UrlAvatar 반환 (전이 단계 지원)
    if (characterSettings == null && photoUrl != null && photoUrl!.isNotEmpty) {
      return UrlAvatar(photoUrl: photoUrl!, size: size, useCircle: useCircle);
    }

    // 3. 캐릭터 설정이 있는 경우
    if (characterSettings != null) {
      Widget avatar = CharacterPartsAvatar(
        settings: characterSettings,
        size: size,
      );

      // 프로필 모드일 경우 얼굴 위주로 확대해서 보여줌
      if (isProfileMode) {
        if (useCircle) {
          return ClipOval(
            child: Transform.translate(
              offset: Offset(0, size * 0.40),
              child: Transform.scale(scale: 1.8, child: avatar),
            ),
          );
        } else {
          return Transform.translate(
            offset: Offset(0, size * 0.40),
            child: Transform.scale(scale: 1.8, child: avatar),
          );
        }
      }
      return avatar;
    }

    // 캐릭터 설정이 없으면 템플릿 또는 기본 아이콘 표시
    if (templateId != null && templateId!.isNotEmpty) {
      return Image.asset(
        Assets.characterPortrait(templateId!),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            Assets.characterBig(templateId!),
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          );
        },
      );
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.transparent,
        shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: useCircle ? null : BorderRadius.circular(20),
      ),
      child: ClipOval(
        clipBehavior: useCircle ? Clip.antiAlias : Clip.none,
        child: CharacterPartsAvatar(
          baseImagePath: Assets.partPath('body_base.png'),
          faceImagePath: Assets.partPath('face_smile.png'),
          hairImagePath: null, // 머리카락 없음
          clothesImagePath: Assets.partPath('clothes_01.png'), // 기본 의상 추가
          size: size,
        ),
      ),
    );
  }
}
