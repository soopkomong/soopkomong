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
            ],
          ),
        ),
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4)],
        ),
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
