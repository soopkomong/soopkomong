import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/auth/widgets/login_buttons.dart';
import 'package:soopkomong/presentation/auth/widgets/policy_links.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // 캐릭터 이미지 (원형 배경)
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5F0E8), // 연한 베이지/크림 배경
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/login.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 앱 이름
              const Text(
                '숲코몽',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // 부제목
              const Text(
                '발걸음이 모이면 모험이 돼요',
                style: TextStyle(
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
}
