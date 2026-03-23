import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/widgets/character_avatar.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:intl/intl.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          isEn ? 'My Page' : '마이페이지',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: [
              const _ProfileCard(),
              const SizedBox(height: 12),
              const _SummaryCards(),
              const SizedBox(height: 12),
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

class _SummaryCards extends ConsumerWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    if (user == null) return const SizedBox.shrink();
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    // 방문한 공원 수 계산 (중복 제외)
    final visitedParksCount = user.acquiredCharacters
        .map((e) => e.discoveredSpotName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: isEn ? 'Parks Visited' : '내가 가본 생태공원',
            count: visitedParksCount,
            iconPath: 'assets/images/park.png',
            color: const Color(0xFF48B200),
            onTap: () => context.goNamed(
              AppRoute.collection.name,
              queryParameters: {'tab': '0'},
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: isEn ? 'Characters Collected' : '내가 모은 캐릭터',
            count: user.acquiredCharacters.length,
            iconPath: 'assets/images/character_silhouette.png',
            color: Colors.black,
            onTap: () => context.goNamed(
              AppRoute.collection.name,
              queryParameters: {'tab': '1'},
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final String iconPath;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.iconPath,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MyPageCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.label.copyWith(color: AppColors.gray900),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Image.asset(iconPath, width: 28, height: 28, color: color),
              const SizedBox(width: 12),
              Text(
                '$count',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    final stepFormat = NumberFormat('#,###');
    final dateFormat = DateFormat('yyyy년 M월 d일 가입');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      user.displayName ?? '사용자',
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
                '총 ${stepFormat.format(user.totalSteps)} 걸음',
                style: AppTextStyles.label.copyWith(color: AppColors.gray800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.gray600,
              ),
              const SizedBox(width: 12),
              Text(
                user.createdAt != null
                    ? dateFormat.format(user.createdAt!)
                    : '가입일 정보 없음',
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '프로필 수정',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoundSection extends ConsumerWidget {
  const SoundSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;
    return MyPageCard(
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
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    return MyPageCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              if (trailing != null)
                Text(trailing!, style: const TextStyle(fontSize: 12)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }
}

class MyPageCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const MyPageCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4)],
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
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(isEn ? 'Delete Account' : '회원 탈퇴'),
                content: Text(
                  isEn
                      ? 'Are you sure you want to delete your account? All data will be permanently deleted.'
                      : '정말로 탈퇴하시겠습니까? 모든 데이터가 영구적으로 삭제됩니다.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(isEn ? 'Cancel' : '취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(isEn ? 'Delete' : '탈퇴'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              // TODO: 회원 탈퇴 로직 구현
            }
          },
          child: Text(
            isEn ? 'Delete Account' : '회원탈퇴',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
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
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
