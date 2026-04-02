import 'package:flutter/material.dart';
import 'package:soopkomong/core/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SettingsCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray50),
        ),
        child: child,
      ),
    );
  }
}
