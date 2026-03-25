import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

/// 개인정보처리방침 & 약관동의 링크 위젯
class PolicyLinks extends ConsumerWidget {
  const PolicyLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showPolicyDialog(
              context,
              isEn ? 'Privacy Policy' : '개인정보처리방침',
              isEn
                  ? 'Privacy policy content is being prepared.'
                  : '개인정보처리방침 내용이 준비 중입니다.',
            );
          },
          child: Text(
            isEn ? 'Privacy Policy' : '개인정보처리방침',
            style: AppTextStyles.label.copyWith(color: AppColors.black),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('|', style: AppTextStyles.label),
        ),
        GestureDetector(
          onTap: () {
            _showPolicyDialog(
              context,
              isEn ? 'Terms of Service' : '약관동의',
              isEn
                  ? 'Terms of service content is being prepared.'
                  : '이용약관 내용이 준비 중입니다.',
            );
          },
          child: Text(
            isEn ? 'Terms of Service' : '약관동의',
            style: AppTextStyles.label.copyWith(color: AppColors.black),
          ),
        ),
      ],
    );
  }

  /// 정책, 약관 내용을 보여주는 바텀시트 다이얼로그
  void _showPolicyDialog(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 핸들 바
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 제목
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  // 내용
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
