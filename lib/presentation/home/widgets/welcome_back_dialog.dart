import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

class WelcomeBackDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isEn;

  const WelcomeBackDialog({
    super.key,
    required this.onConfirm,
    this.isEn = false,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    bool isEn = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WelcomeBackDialog(
        onConfirm: onConfirm,
        isEn: isEn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(20),
      title: Text(
        isEn ? 'Welcome back!' : '반가워요!',
        style: AppTextStyles.title,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEn
                ? 'You\'re back!\nYour collected encyclopedia and records\nare kept safe.'
                : '다시 돌아오셨군요!\n기존에 모았던 도감과 기록들은\n그대로 안전하게 보관되어 있어요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 20),
          Text(
            isEn
                ? 'Now, shall we enjoy the rest of the adventure?'
                : '자, 이제 남은 모험을 다시 즐겨볼까요?',
            textAlign: TextAlign.center,
            style: AppTextStyles.subTitleM.copyWith(
              color: AppColors.primary700,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isEn ? 'Great!' : '좋아요!',
              style: AppTextStyles.subTitleL,
            ),
          ),
        ),
      ],
    );
  }
}
