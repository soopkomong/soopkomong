import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

class UpdateNoticeDialog extends StatelessWidget {
  final bool isEn;

  const UpdateNoticeDialog({super.key, required this.isEn});

  static Future<void> show(BuildContext context, {required bool isEn}) {
    return showDialog(
      context: context,
      builder: (context) => UpdateNoticeDialog(isEn: isEn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEn ? 'Update Notice' : '업데이트 공지',
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.campaign, color: AppColors.primary700, size: 48),
          const SizedBox(height: 16),
          Text(
            isEn
                ? '2026-03-29 23:00 (UTC+9)\nA brand new character is coming!'
                : '2026년 3월 29일 23:00 업데이트 예정\n새로운 캐릭터가 추가됩니다!',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isEn ? 'Close' : '닫기'),
        ),
      ],
    );
  }
}
