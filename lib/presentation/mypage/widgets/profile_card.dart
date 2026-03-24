import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/character_avatar.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final user = ref.watch(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    final stepFormat = NumberFormat('#,###');
    final dateFormat = isEn
        ? DateFormat('MMM d, yyyy')
        : DateFormat('yyyy년 M월 d일');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile circular avatar
              UserAvatar(
                characterSettings: user.characterSettings,
                photoUrl: user.photoUrl,
                size: 80,
                isProfileMode: true,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? (isEn ? 'User' : '사용자'),
                      style: AppTextStyles.subTitleL.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.userCode ?? '',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats section
          Row(
            children: [
              Image.asset(
                'assets/images/footprints.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(width: 12),
              Text(
                isEn
                    ? '${stepFormat.format(user.totalSteps)} Total Steps'
                    : '총 ${stepFormat.format(user.totalSteps)} 걸음',
                style: AppTextStyles.label.copyWith(color: AppColors.gray800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.gray600,
              ),
              const SizedBox(width: 12),
              Text(
                user.createdAt != null
                    ? (isEn
                          ? 'Joined ${dateFormat.format(user.createdAt!)}'
                          : '${dateFormat.format(user.createdAt!)} 가입')
                    : (isEn ? 'No join date' : '가입일 정보 없음'),
                style: AppTextStyles.label.copyWith(color: AppColors.gray800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Edit Profile Button
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRoute.profileEdit.name);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEn ? 'Edit Profile' : '프로필 수정',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.gray900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
