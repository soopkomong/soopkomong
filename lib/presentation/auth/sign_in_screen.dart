import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '발걸음이 모이면 모험이 돼요',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // 구글 로그인 버튼
            ElevatedButton.icon(
              onPressed: () => _signInWithGoogle(context, ref),
              icon: const Icon(Icons.login),
              label: const Text('구글로 로그인하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // 카카오 로그인 버튼
            ElevatedButton.icon(
              onPressed: () => _signInWithKakao(context, ref),
              icon: const Icon(Icons.chat_bubble),
              label: const Text('카카오로 로그인하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: const Color(0xFF191919),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 실패: $e')),
        );
      }
    }
  }

  Future<void> _signInWithKakao(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signInWithKakao();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $e')),
        );
      }
    }
  }
}

