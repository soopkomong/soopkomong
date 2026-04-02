import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/widgets/url_avatar.dart';

class FriendRequestDialog extends StatelessWidget {
  final String nickname;
  final String? photoUrl;
  final bool isEn;
  final VoidCallback onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onClose;

  const FriendRequestDialog({
    super.key,
    required this.nickname,
    this.photoUrl,
    required this.isEn,
    required this.onConfirm,
    this.onReject,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required String nickname,
    String? photoUrl,
    required bool isEn,
    required VoidCallback onConfirm,
    VoidCallback? onReject,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FriendRequestDialog(
        nickname: nickname,
        photoUrl: photoUrl,
        isEn: isEn,
        onConfirm: onConfirm,
        onReject: onReject,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onClose?.call();
                },
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.gray800,
                  size: 28,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: UrlAvatar(
                    photoUrl: photoUrl ?? '',
                    size: 100,
                    useCircle: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEn ? 'New Friend Request!' : '친구 신청이 왔어요!',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isEn
                      ? 'Friend request arrived from \'$nickname\'.'
                      : '\'$nickname\' 님에게 친구 신청이 도착했어요',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary700,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isEn ? 'Accept' : '수락하기',
                            style: AppTextStyles.subTitleL,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onReject?.call();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.gray100,
                            foregroundColor: AppColors.gray500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isEn ? 'Reject' : '거절하기',
                            style: AppTextStyles.subTitleL,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
