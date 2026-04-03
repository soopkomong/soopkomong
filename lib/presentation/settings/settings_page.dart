import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/version_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/withdraw_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'widgets/setting_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        title: Text(isEn ? 'Settings' : '설정'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            children: [
              SettingTile(
                title: isEn ? 'Language' : '언어',
                trailing: ref.watch(localeProvider).label,
                onTap: () => _showLanguageDialog(context, ref),
              ),
              const SizedBox(height: 12),
              SettingTile(
                title: isEn ? 'Privacy Policy' : '개인정보 처리 방침',
                onTap: () => launchUrl(
                  Uri.parse(
                    isEn
                        ? 'https://shine-science-804.notion.site/Privacy-Policy-Effective-Date-March-24-2026-333694d9a11d8023a8becfca169a6b6d?source=copy_link'
                        : 'https://shine-science-804.notion.site/2026-03-24-32d694d9a11d806cba95cccb781d4a13',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SettingTile(
                title: isEn ? 'Terms of Service' : '이용 약관',
                onTap: () => launchUrl(
                  Uri.parse(
                    isEn
                        ? 'https://shine-science-804.notion.site/Terms-of-Service-Effective-Date-March-24-2026-333694d9a11d809b8a13c38797a6828b?source=copy_link'
                        : 'https://shine-science-804.notion.site/2026-03-24-32d694d9a11d80c0980efa43bec9f0c7?pvs=74',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SettingTile(
                title: isEn ? 'Version' : '버전',
                trailing: ref
                    .watch(packageInfoProvider)
                    .when(
                      data: (packageInfo) => packageInfo.version,
                      loading: () => '...',
                      error: (_, _) => '1.0.0',
                    ),
                onTap: null,
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 40),
              _BottomActions(ref: ref),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final isEn = ref.read(localeProvider) == AppLocale.en;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  isEn ? 'Select Language' : '언어 선택',
                  style: AppTextStyles.subTitleL,
                ),
              ),
              ListTile(
                title: Text(
                  isEn ? 'Korean (한국어)' : '한국어',
                  style: AppTextStyles.subTitleL,
                ),
                trailing: ref.watch(localeProvider) == AppLocale.ko
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(AppLocale.ko);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English', style: AppTextStyles.subTitleL),
                trailing: ref.watch(localeProvider) == AppLocale.en
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(AppLocale.en);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  final WidgetRef ref;
  const _BottomActions({required this.ref});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final locale = ref.read(localeProvider);
    final isEn = locale == AppLocale.en;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isEn ? 'Log Out' : '로그아웃',
          style: AppTextStyles.subTitleL.copyWith(color: AppColors.gray900),
        ),
        content: Text(
          isEn ? 'Would you like to log out?' : '로그아웃 하시겠습니까?',
          style: AppTextStyles.body.copyWith(color: AppColors.gray600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              isEn ? 'No' : '아니오',
              style: AppTextStyles.body.copyWith(color: AppColors.gray500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              isEn ? 'Yes' : '예',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => WithdrawDialog.show(context),
          child: Text(
            isEn ? 'Delete Account' : '회원탈퇴',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(
          height: 12,
          child: VerticalDivider(color: Colors.grey, thickness: 1, width: 1),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showLogoutDialog(context),
          child: Text(
            isEn ? 'Log Out' : '로그아웃',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
