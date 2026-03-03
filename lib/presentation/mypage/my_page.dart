import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_route.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              title: const Text('마이페이지', style: TextStyle(color: Colors.black)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: const [
                    _ProfileSection(),
                    SizedBox(height: 28),
                    StatsSection(),
                    SizedBox(height: 28),
                    SoundSection(),
                    SizedBox(height: 16),
                    SettingTile(title: '언어', trailing: '한국어'),
                    SizedBox(height: 16),
                    SettingTile(title: '개인정보 처리 방침'),
                    SizedBox(height: 16),
                    SettingTile(title: '이용 약관'),
                    SizedBox(height: 40),
                    BottomActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: Image.network(
                'https://picsum.photos/seed/1/358/199',
              ).image,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Name',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: '내가 가본 생태공원',
            value: '8',
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
            title: '내가 모은 캐릭터',
            value: '25',
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

class SoundSection extends StatelessWidget {
  const SoundSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '소리',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12),
          SwitchTile(title: '배경음'),
          SwitchTile(title: '진동'),
          SwitchTile(title: '효과음'),
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

  const SettingTile({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
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

class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: const Text(
            '회원탈퇴',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        SizedBox(width: 8),
        VerticalDivider(),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () {},
          child: const Text(
            '로그아웃',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
