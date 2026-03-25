import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/auth/widgets/login_buttons.dart';
import 'package:soopkomong/presentation/auth/widgets/policy_links.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    // 회원 탈퇴 팝업 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(showWithdrawalPopupProvider)) {
        _showWithdrawalCompleteDialog(context, ref, isEn);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 캐릭터 이미지 (원형 배경)
              Container(
                width: 250,
                height: 200,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Image.asset(
                    'assets/images/Login_character.png',
                    width: 249,
                    height: 189,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 앱 이름
              Text(
                isEn ? 'Soopkomong' : '숲코몽',
                style: AppTextStyles.headline.copyWith(color: AppColors.black),
              ),

              const SizedBox(height: 8),

              // 부제목
              Text(
                isEn ? 'Every step turns into an adventure' : '발걸음이 모이면 모험이 돼요',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF888888),
                ),
              ),

              const Spacer(flex: 2),

              // 로그인 버튼 영역
              const LoginButtons(),

              const SizedBox(height: 20),

              // 개인정보처리방침 | 약관동의
              const PolicyLinks(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalCompleteDialog(
    BuildContext context,
    WidgetRef ref,
    bool isEn,
  ) {
    // 팝업을 띄우기 전에 상태를 먼저 리셋하여 중복 노출 방지
    ref.read(showWithdrawalPopupProvider.notifier).set(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEn ? 'Withdrawal Complete' : '회원 탈퇴 완료',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isEn
              ? 'Your account has been withdrawn. You cannot re-register for 14 days after withdrawal. Please return after 14 days.'
              : '회원 탈퇴 처리되었습니다.\n탈퇴 후 14일 동안은 재가입이 불가능하며, 14일 이후에 다시 이용해 주시기 바랍니다.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEn ? 'Confirm' : '확인',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
