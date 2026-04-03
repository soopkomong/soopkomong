import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class ParkUnlockedDialog extends StatelessWidget {
  final String parkName;
  final String imageUrl;
  final VoidCallback onConfirm;
  final bool isEn;

  const ParkUnlockedDialog({
    super.key,
    required this.parkName,
    required this.imageUrl,
    required this.onConfirm,
    this.isEn = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String parkName,
    required String imageUrl,
    required VoidCallback onConfirm,
    bool isEn = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ParkUnlockedDialog(
        parkName: parkName,
        imageUrl: imageUrl,
        onConfirm: onConfirm,
        isEn: isEn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheHeight: 400, // 다이얼로그용 크기에 최적화
                placeholder: (context, url) => Container(
                  height: 180,
                  color: AppColors.gray100,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: AppColors.gray200,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // 공원 이름
                  Text(
                    parkName,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 안내 문구 (시안 문구 반영: 2줄)
                  Text(
                    isEn
                        ? '$parkName has been unlocked!\nWalk in the park to get an egg!'
                        : '$parkName에 도착해서\n도감 잠금이 해제 되었어요!\n공원에서 걸으면 알을 획득할 수 있어요!',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // 하단 풀 너비 '확인' 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary700,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEn ? 'Confirm' : '확인',
                        style: AppTextStyles.subTitleL,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
