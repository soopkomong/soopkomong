import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 개인정보처리방침 & 약관동의 링크 위젯
class PolicyLinks extends ConsumerWidget {
  const PolicyLinks({super.key});

  static const String _privacyPolicyUrl =
      'https://shine-science-804.notion.site/2026-03-24-32d694d9a11d806cba95cccb781d4a13';
  static const String _privacyPolicyUrlEn =
      'https://shine-science-804.notion.site/Privacy-Policy-Effective-Date-March-24-2026-333694d9a11d8023a8becfca169a6b6d?source=copy_link';

  static const String _termsOfServiceUrl =
      'https://shine-science-804.notion.site/2026-03-24-32d694d9a11d80c0980efa43bec9f0c7?pvs=74';
  static const String _termsOfServiceUrlEn =
      'https://shine-science-804.notion.site/Terms-of-Service-Effective-Date-March-24-2026-333694d9a11d809b8a13c38797a6828b?source=copy_link';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _launchURL(isEn ? _privacyPolicyUrlEn : _privacyPolicyUrl),
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
          onTap: () => _launchURL(isEn ? _termsOfServiceUrlEn : _termsOfServiceUrl),
          child: Text(
            isEn ? 'Terms of Service' : '약관동의',
            style: AppTextStyles.label.copyWith(color: AppColors.black),
          ),
        ),
      ],
    );
  }

  /// 외부 URL 링크 연결
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}
