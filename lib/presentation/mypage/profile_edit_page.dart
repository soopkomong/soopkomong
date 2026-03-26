import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/widgets/url_avatar.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 초기 닉네임 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider).value;
      if (user != null) {
        _nicknameController.text = user.displayName ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoute.mypage.path);
            }
          },
        ),
        title: const Text(
          '프로필 수정',
          style: AppTextStyles.title,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Avatar Center
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: UrlAvatar(
                      photoUrl: user.photoUrl ?? '',
                      size: 152,
                      useCircle: true,
                    ),
                  ),
                  // Pencil Icon
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRoute.characterCustomize.name);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gray400,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Nickname Label
            const Text('닉네임', style: AppTextStyles.subTitleL),
            const SizedBox(height: 12),
            // Nickname Input
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: '닉네임을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.gray100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.gray100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary700),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary700,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('저장하기', style: AppTextStyles.subTitleL),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final newNickname = _nicknameController.text.trim();
    if (newNickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),
      );
      return;
    }

    try {
      await ref.read(authRepositoryProvider).updateDisplayName(newNickname);
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoute.mypage.path);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 수정되었습니다.'),
            behavior: SnackBarBehavior.floating,
            elevation: 4,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('수정 실패: $e'),
            behavior: SnackBarBehavior.floating,
            elevation: 4,
          ),
        );
      }
    }
  }
}
