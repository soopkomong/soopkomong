import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

/// 로그인 버튼 위젯 (카카오, 구글, 애플)
class LoginButtons extends ConsumerWidget {
  const LoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final isLoading = ref.watch(authLoadingProvider);

    return Column(
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A8D6D)),
            ),
          ),
        // 카카오 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _signInWithKakao(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE500),
              foregroundColor: const Color(0xFF191919),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 카카오 말풍선 아이콘
                const Icon(
                  Icons.chat_bubble,
                  size: 18,
                  color: Color(0xFF191919),
                ),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Continue with Kakao' : '카카오로 시작하기',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 구글 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => _signInWithGoogle(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 구글 아이콘
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Continue with Google' : '구글로 시작하기',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 애플 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _signInWithApple(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, size: 22),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Continue with Apple' : '애플로 시작하기',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 구글 로그인 처리
  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    final isEn = ref.read(localeProvider) == AppLocale.en;
    ref.read(authLoadingProvider.notifier).set(true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(isEn ? 'Google login failed: $e' : '구글 로그인 실패: $e')));
      }
    } finally {
      ref.read(authLoadingProvider.notifier).set(false);
    }
  }

  /// 카카오 로그인 처리
  Future<void> _signInWithKakao(BuildContext context, WidgetRef ref) async {
    final isEn = ref.read(localeProvider) == AppLocale.en;
    ref.read(authLoadingProvider.notifier).set(true);
    try {
      await ref.read(authRepositoryProvider).signInWithKakao();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(isEn ? 'Kakao login failed: $e' : '카카오 로그인 실패: $e')));
      }
    } finally {
      ref.read(authLoadingProvider.notifier).set(false);
    }
  }

  /// 애플 로그인 처리
  Future<void> _signInWithApple(BuildContext context, WidgetRef ref) async {
    final isEn = ref.read(localeProvider) == AppLocale.en;
    ref.read(authLoadingProvider.notifier).set(true);
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(isEn ? 'Apple login failed: $e' : '애플 로그인 실패: $e')));
      }
    } finally {
      ref.read(authLoadingProvider.notifier).set(false);
    }
  }
}
