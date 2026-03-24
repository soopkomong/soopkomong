import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/withdraw_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEn ? 'Settings' : '설정',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: [
              const SoundSection(),
              const SizedBox(height: 12),
              SettingTile(
                title: isEn ? 'Language' : '언어',
                trailing: ref.watch(localeProvider).label,
                onTap: () => _showLanguageDialog(context, ref),
              ),
              const SizedBox(height: 16),
              SettingTile(title: isEn ? 'Privacy Policy' : '개인정보 처리 방침'),
              const SizedBox(height: 16),
              SettingTile(title: isEn ? 'Terms of Service' : '이용 약관'),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(isEn ? 'Korean (한국어)' : '한국어'),
                trailing: ref.watch(localeProvider) == AppLocale.ko
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(AppLocale.ko);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
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

class SoundSection extends ConsumerWidget {
  const SoundSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Sound' : '소리',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SwitchTile(title: isEn ? 'BGM' : '배경음'),
          SwitchTile(title: isEn ? 'Vibration' : '진동'),
          SwitchTile(title: isEn ? 'SFX' : '효과음'),
        ],
      ),
    );
  }
}

class SwitchTile extends StatelessWidget {
  final String title;

  const SwitchTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      activeColor: const Color(0xFF48B200),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: true,
      onChanged: (v) {},
    );
  }
}

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
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
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
        title: Text(isEn ? 'Log Out' : '로그아웃'),
        content: Text(isEn ? 'Would you like to log out?' : '로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isEn ? 'No' : '아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isEn ? 'Yes' : '예'),
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
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Colors.grey,
            ),
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
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
