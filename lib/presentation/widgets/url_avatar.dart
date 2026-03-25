import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 실제 프로필 사진(URL)을 보여주는 전용 위젯
class UrlAvatar extends StatelessWidget {
  final String photoUrl;
  final double size;
  final bool useCircle;

  const UrlAvatar({
    super.key,
    required this.photoUrl,
    this.size = 80,
    this.useCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: photoUrl,
      width: size,
      height: size,
      fit: useCircle ? BoxFit.cover : BoxFit.contain,
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: useCircle ? null : BorderRadius.circular(20),
        ),
      ),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
    );

    if (!useCircle) {
      return SizedBox(width: size, height: size, child: image);
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: image),
    );
  }

  Widget _buildErrorPlaceholder() {
    final displaySize = size > 140 ? 140.0 : size;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7ED), // ProfileCard와 같은 연한 연두색 배경
        shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: useCircle ? null : BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: displaySize * 0.5,
          color: const Color(0xFFB0BEC5), // 조금 더 부드러운 회색
        ),
      ),
    );
  }
}
