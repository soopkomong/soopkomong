import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'settings_card.dart';

class SoundSection extends ConsumerWidget {
  const SoundSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(localeProvider) == AppLocale.en;
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Sound' : '소리',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SwitchTile(title: isEn ? 'BGM' : '배경음'),
          SwitchTile(title: isEn ? 'Vibration' : '진동'),
          SwitchTile(title: isEn ? 'SFX' : '효과음'),
        ],
      ),
    );
  }
}

class SwitchTile extends StatelessWidget {
  final String title;

  const SwitchTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      activeColor: const Color(0xFF48B200),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: true,
      onChanged: (v) {},
    );
  }
}
