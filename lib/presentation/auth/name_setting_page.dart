import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/core/utils/app_toast.dart';

class NameSettingPage extends ConsumerStatefulWidget {
  const NameSettingPage({super.key});

  @override
  ConsumerState<NameSettingPage> createState() => _NameSettingPageState();
}

class _NameSettingPageState extends ConsumerState<NameSettingPage> {
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _onSave() async {
    final name = _nicknameController.text.trim();
    final isEn = ref.read(localeProvider) == AppLocale.en;

    if (name.isEmpty) {
      AppToast.show(context, isEn ? 'Please enter a nickname' : '닉네임을 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).updateDisplayName(name);
      if (mounted) {
        // 성공 시 홈으로 이동 (라우터에서 리다이렉트 처리되지만 명시적으로 이동)
        context.goNamed(AppRoute.home.name);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, isEn ? 'Save failed: $e' : '저장 실패: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          isEn ? 'Set Nickname' : '닉네임 설정',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                isEn
                    ? 'What should we call you?'
                    : '숲코몽에서 사용할\n이름을 정해주세요!',
                style: AppTextStyles.headline.copyWith(height: 1.4),
              ),
              const SizedBox(height: 48),
              Text(isEn ? 'Nickname' : '닉네임', style: AppTextStyles.subTitleL),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isEn ? 'Enter nickname' : '닉네임을 입력하세요',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.gray100),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.gray100),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.primary700),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => _onSave(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary700,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEn ? 'Confirm' : '확인',
                      style: AppTextStyles.subTitleL.copyWith(
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
