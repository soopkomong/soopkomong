import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'settings_card.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.subTitleM.copyWith(color: AppColors.gray900),
          ),
          Row(
            children: [
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppTextStyles.label.copyWith(color: AppColors.gray900),
                ),
              const SizedBox(width: 4),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.gray900),
            ],
          ),
        ],
      ),
    );
  }
}
