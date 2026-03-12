import 'package:flutter/material.dart';

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

  const CharacterAvatar({
    super.key,
    this.baseImagePath = 'assets/images/parts/body_base.png',
    this.bodyShadowImagePath,
    this.baseColor = Colors.white,
    this.clothesImagePath = 'assets/images/parts/clothes_01.png',
    this.clothesColor = Colors.white,
    this.shoesImagePath,
    this.shoesColor = Colors.white,
    this.faceImagePath = 'assets/images/parts/face_smile.png',
    this.hairImagePath = 'assets/images/parts/hair_01.png',
    this.hairSubShadowImagePath,
    this.hairShadowImagePath,
    this.hairHighlightImagePath,
    this.hairColor = Colors.white,
    this.size = 250.0,
  });

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
