import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

class WelcomeBackDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const WelcomeBackDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WelcomeBackDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '반가워요!',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '다시 돌아오셨군요!\n기존에 모았던 도감과 기록들은\n그대로 안전하게 보관되어 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5),
          ),
          SizedBox(height: 12),
          Text(
            '자, 이제 남은 모험을 다시 즐겨볼까요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '좋아요!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
