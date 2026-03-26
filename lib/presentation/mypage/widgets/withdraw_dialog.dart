import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class WithdrawDialog extends ConsumerWidget {
  const WithdrawDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const WithdrawDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return AlertDialog(
      title: Text(isEn ? 'Delete Account' : '회원 탈퇴'),
      content: Text(
        isEn
            ? 'Are you sure you want to delete your account? All data will be preserved for 14 days and then deleted.'
            : '정말로 탈퇴하시겠습니까?\n프로필, 캐릭터, 도감 등 모든 정보는 14일간 보관 후 삭제됩니다.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.gray900),
          child: Text(isEn ? 'Cancel' : '취소'),
        ),
        TextButton(
          onPressed: () => _handleWithdrawFlow(context, ref, isEn),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(isEn ? 'Confirm' : '확인'),
        ),
      ],
    );
  }

  Future<void> _handleWithdrawFlow(
    BuildContext context,
    WidgetRef ref,
    bool isEn,
  ) async {
    // 1. 본인 재확인을 위한 소셜 로그인 팝업
    final reAuthenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ReAuthDialog(isEn: isEn),
    );

    if (reAuthenticated == true) {
      if (!context.mounted) return;

      // 원본 WithdrawDialog를 먼저 닫아서 나중에 발생할 수 있는 충돌을 방지합니다.
      Navigator.of(context).pop();

      // 로딩 표시 (rootNavigator 사용)
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary700),
        ),
      );

      try {
        await ref.read(authRepositoryProvider).withdraw();
        ref.read(showWithdrawalPopupProvider.notifier).set(true);

        // 성공 시: AppRouter에서 authStateChanges를 리스닝하여 자동으로 리다이렉트됩니다.
        // GoRouter.go()에 의해 전체 페이지 스택(다이얼로그 포함)이 초기화되고 /signIn으로 이동하므로
        // 여기서 명시적으로 pop()을 다시 호출하면 안 됩니다. (호출 시 새로 뜬 로그인 페이지가 닫혀 블랙스크린 발생)

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEn
                    ? 'Your account withdrawal request has been submitted.'
                    : '회원 탈퇴 요청이 완료되었습니다.',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // 에러 발생 시 로딩 팝업 제거
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Withdrawal failed: $e')));
        }
      }
    }
  }
}

class _ReAuthDialog extends ConsumerWidget {
  final bool isEn;
  const _ReAuthDialog({required this.isEn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authRepositoryProvider).currentUser;
    final providerId = user?.providerId;

    return AlertDialog(
      title: Text(isEn ? 'Re-authentication' : '본인 재확인'),
      content: Text(
        isEn
            ? 'Please sign in again with your social account to confirm deletion.'
            : '연동된 소셜 계정으로 다시 로그인하여 본인임을 확인해 주세요.',
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (providerId == 'google.com' || providerId == null)
              _SocialAuthButton(
                icon: Icons.login,
                label: 'Google',
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signInWithGoogle();
                    if (context.mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop(true);
                        }
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            if (providerId == 'oidc.kakao' || providerId == null)
              _SocialAuthButton(
                icon: Icons.login,
                label: 'Kakao',
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signInWithKakao();
                    if (context.mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop(true);
                        }
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            if (providerId == 'apple.com' || providerId == null)
              _SocialAuthButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signInWithApple();
                    if (context.mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop(true);
                        }
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: AppColors.gray900),
              child: Text(isEn ? 'Close' : '닫기'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray900,
          side: const BorderSide(color: AppColors.gray300),
        ),
      ),
    );
  }
}
