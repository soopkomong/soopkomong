import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';

enum NotificationType { friendRequest, notice, eggObtained, eggHatched }

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final NotificationType type;
  final String? characterTemplateId; // 친구 신청일 경우 캐릭터 ID
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? statusText; // '수락됨', '거절됨' 등 상태 표시

  const NotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    this.characterTemplateId,
    this.onAccept,
    this.onDecline,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray50, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.subTitleM),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (type == NotificationType.eggHatched &&
                characterTemplateId != null &&
                characterTemplateId!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary100.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/characters/${characterTemplateId}_big.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
            if (type == NotificationType.friendRequest &&
                statusText == null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    label: '거절',
                    onPressed: onDecline,
                    isPrimary: false,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    label: '수락',
                    onPressed: onAccept,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                date,
                style: const TextStyle(fontSize: 11, color: AppColors.gray400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    switch (type) {
      case NotificationType.notice:
        return _buildCircleIcon(
          size: 40,
          backgroundColor: AppColors.primary700,
          child: const Icon(Icons.notifications, color: Colors.white, size: 20),
        );
      case NotificationType.eggObtained:
        return _buildCircleIcon(
          size: 40,
          backgroundColor: AppColors.primary100,
          child: Image.asset(
            'assets/images/egg/egg_mystery.png',
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.egg, color: AppColors.primary700, size: 20),
          ),
        );
      case NotificationType.eggHatched:
        return _buildCircleIcon(
          size: 40, // 다른 아이콘과 크기 통일
          backgroundColor: AppColors.primary100,
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.primary700,
            size: 20,
          ),
        );
      case NotificationType.friendRequest:
        return _buildCircleIcon(
          size: 40,
          backgroundColor: AppColors.gray50,
          child: ClipOval(
            child:
                (characterTemplateId != null && characterTemplateId!.isNotEmpty)
                ? Image.asset(
                    'assets/images/characters/${characterTemplateId}_big.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: AppColors.gray300),
                  )
                : const Icon(Icons.person, color: AppColors.gray300),
          ),
        );
    }
  }

  Widget _buildCircleIcon({
    required double size,
    required Color backgroundColor,
    required Widget child,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary700 : AppColors.gray50,
          foregroundColor: isPrimary ? Colors.white : AppColors.gray600,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
