import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/utils/auth_error_handler.dart';
import 'package:soopkomong/core/utils/app_toast.dart';

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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary700),
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
              foregroundColor: AppColors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 카카오 로고 아이콘
                SvgPicture.asset(
                  'assets/images/kakao.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Continue with Kakao' : '카카오로 시작하기',
                  style: AppTextStyles.subTitleL.copyWith(
                    color: AppColors.gray900,
                  ),
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
              foregroundColor: AppColors.gray900,
              side: const BorderSide(color: AppColors.gray200, width: 1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 구글 로고 아이콘
                SvgPicture.asset(
                  'assets/images/google.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Continue with Google' : '구글로 시작하기',
                  style: AppTextStyles.subTitleL.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (Platform.isIOS || Platform.isMacOS) ...[
          const SizedBox(height: 10),

          // 애플 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => _signInWithApple(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 애플 로고 아이콘
                  SvgPicture.asset(
                    'assets/images/applelogo.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Continue with Apple' : '애플로 시작하기',
                    style: AppTextStyles.subTitleL.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        final errorMessage = AuthErrorHandler.getErrorMessage(e, isEn);
        AppToast.show(context, errorMessage);
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
        final errorMessage = AuthErrorHandler.getErrorMessage(e, isEn);
        AppToast.show(context, errorMessage);
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
        final errorMessage = AuthErrorHandler.getErrorMessage(e, isEn);
        AppToast.show(context, errorMessage);
      }
    } finally {
      ref.read(authLoadingProvider.notifier).set(false);
    }
  }
}
