import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/widgets/character_avatar.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    const _ProfileSection(),
                    const SizedBox(height: 28),
                    const _StatsSection(),
                    const SizedBox(height: 28),
                    const SoundSection(),
                    const SizedBox(height: 16),
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
          ],
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
              ),
              child: ClipOval(
                child: Center(
                  child: user.characterSettings != null
                      ? Transform.translate(
                          offset: const Offset(
                            0,
                            45,
                          ), // 배율 하향에 맞춰 위치 조정 (60 -> 45)
                          child: Transform.scale(
                            scale: 1.5, // 너무 과하지 않게 확대 배율 소폭 하향 (1.8 -> 1.5)
                            child: CharacterAvatar(
                              baseImagePath:
                                  'assets/images/parts/body_base.png',
                              bodyShadowImagePath:
                                  'assets/images/parts/body_shadow.png',
                              baseColor: Color(
                                user.characterSettings!['skinColor'] as int,
                              ),
                              hairImagePath:
                                  'assets/images/parts/hair_${user.characterSettings!['hair']}.png',
                              hairHighlightImagePath:
                                  'assets/images/parts/hair_${user.characterSettings!['hair']}_highlight.png',
                              hairShadowImagePath:
                                  'assets/images/parts/hair_${user.characterSettings!['hair']}_shadow.png',
                              hairSubShadowImagePath:
                                  'assets/images/parts/hair_${user.characterSettings!['hair']}_sub_shadow.png',
                              hairColor: Color(
                                user.characterSettings!['hairColor'] as int,
                              ),
                              faceImagePath:
                                  'assets/images/parts/face_${user.characterSettings!['face']}.png',
                              clothesImagePath:
                                  'assets/images/parts/clothes_${user.characterSettings!['clothes']}.png',
                              clothesColor: Color(
                                user.characterSettings!['clothesColor'] as int,
                              ),
                              shoesImagePath:
                                  user.characterSettings!['shoes'] != null
                                  ? 'assets/images/parts/shoes_${user.characterSettings!['shoes']}.png'
                                  : null,
                              shoesColor: Color(
                                user.characterSettings!['shoesColor'] as int,
                              ),
                              size: 200,
                            ),
                          ),
                        )
                      : Image.network(
                          user.photoUrl ??
                              'https://picsum.photos/seed/1/358/199',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.pushNamed(AppRoute.characterCustomize.name);
                },
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'Name',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final locationsAsync = ref.watch(filteredLocationsProvider);
    final userCharacters = ref.watch(userSoopkomonProvider);

    final visitedCount = locationsAsync.maybeWhen(
      data: (locations) => locations.where((l) => l.isVisited == true).length,
      orElse: () => 0,
    );

    return Row(
      children: [
        Expanded(
          child: StatCard(
            onTap: () {
              context.goNamed(
                AppRoute.collection.name,
                queryParameters: {'tab': '0'},
              );
            },
            title: isEn ? 'Parks Visited' : '내가 가본 생태공원',
            value: visitedCount.toString(),
            image: 'assets/images/park.png',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            onTap: () {
              context.goNamed(
                AppRoute.collection.name,
                queryParameters: {'tab': '1'},
              );
            },
            title: isEn ? 'Characters Collected' : '내가 모은 캐릭터',
            value: (userCharacters.value?.length ?? 0).toString(),
            image: 'assets/images/character_silhouette.png',
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String image;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Image.asset(image, width: 28, height: 28),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Card(
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

  const SettingTile({super.key, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
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

class Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const Card({super.key, required this.child, this.onTap});

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
