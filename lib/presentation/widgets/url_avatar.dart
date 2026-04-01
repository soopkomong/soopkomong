import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

/// 실제 프로필 사진(URL)을 보여주는 전용 위젯
class UrlAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final bool useCircle;

  const UrlAvatar({
    super.key,
    this.photoUrl,
    this.size = 80,
    this.useCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _buildErrorPlaceholder();
    }

    final image = CachedNetworkImage(
      imageUrl: photoUrl!,
      width: size,
      height: size,
      memCacheWidth: (size * 2).toInt(),
      memCacheHeight: (size * 2).toInt(),
      fit: useCircle ? BoxFit.cover : BoxFit.contain,
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
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
        color: AppColors.primary100, // 배경색 변경
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
        color: AppColors.primary100, // 배경색 변경
        shape: useCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: useCircle ? null : BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: displaySize * 0.5,
          color: AppColors.gray300, // 회색으로 변경
        ),
      ),
    );
  }
}
