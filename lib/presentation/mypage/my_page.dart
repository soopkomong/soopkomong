import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/mypage/widgets/profile_card.dart';
import 'package:soopkomong/presentation/mypage/widgets/visited_parks_section.dart';
import 'package:soopkomong/presentation/mypage/widgets/collected_characters_section.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          isEn ? 'My Page' : '마이페이지',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            children: const [
              ProfileCard(),
              SizedBox(height: 12),
              VisitedParksSection(),
              SizedBox(height: 12),
              CollectedCharactersSection(),
            ],
          ),
        ),
      ),
    );
  }
}
