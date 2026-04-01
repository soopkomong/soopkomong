import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/url_avatar.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final user = ref.watch(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    final stepFormat = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile circular avatar
              UrlAvatar(
                photoUrl: user.photoUrl ?? '',
                size: 80,
                useCircle: true,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? (isEn ? 'User' : '사용자'),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/footprints.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary700,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isEn
                              ? '${stepFormat.format(user.totalSteps)} Total Steps'
                              : '총 ${stepFormat.format(user.totalSteps)} 걸음',
                          style: AppTextStyles.subTitleL.copyWith(
                            color: AppColors.primary700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Edit Profile Button
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRoute.profileEdit.name);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEn ? 'Edit Profile' : '프로필 수정',
                textAlign: TextAlign.center,
                style: AppTextStyles.subTitleM.copyWith(
                  color: AppColors.gray800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
