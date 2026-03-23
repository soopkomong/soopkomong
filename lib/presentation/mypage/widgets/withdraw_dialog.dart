import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
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
          child: Text(isEn ? 'Cancel' : '취소'),
        ),
        TextButton(
          onPressed: () => _handleWithdrawFlow(context, ref, isEn),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
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
    // 1. 첫 번째 확인 팝업 닫기 (true 반환하여 진행 의사 표시)
    Navigator.of(context).pop(true);

    // 2. 본인 재확인을 위한 소셜 로그인 팝업
    final reAuthenticated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ReAuthDialog(isEn: isEn),
    );

    if (reAuthenticated == true) {
      try {
        await ref.read(authRepositoryProvider).withdraw();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? 'Your account withdrawal request has been submitted.'
                  : '회원 탈퇴 요청이 완료되었습니다.',
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal failed: $e')),
        );
      }
    }
  }
}

class _ReAuthDialog extends ConsumerWidget {
  final bool isEn;
  const _ReAuthDialog({required this.isEn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _SocialAuthButton(
              icon: Icons.login,
              label: 'Google',
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signInWithGoogle();
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            _SocialAuthButton(
              icon: Icons.login,
              label: 'Kakao',
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signInWithKakao();
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            _SocialAuthButton(
              icon: Icons.apple,
              label: 'Apple',
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signInWithApple();
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
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
      ),
    );
  }
}
