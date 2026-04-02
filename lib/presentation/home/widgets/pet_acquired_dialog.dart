import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';

class PetAcquiredDialog extends ConsumerWidget {
  final String petName;
  final String parkName;
  final String eggPath;
  final bool isEn;

  const PetAcquiredDialog({
    super.key,
    required this.petName,
    required this.parkName,
    required this.eggPath,
    required this.isEn,
  });

  static Future<void> show(
    BuildContext context, {
    required String petName,
    required String parkName,
    required String eggPath,
    required bool isEn,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PetAcquiredDialog(
        petName: petName,
        parkName: parkName,
        eggPath: eggPath,
        isEn: isEn,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 알 이미지
            Image.asset(
              eggPath,
              width: 110,
              height: 110,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.egg_rounded,
                size: 100,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 20),
            // 타이틀 (예: 의왕레일파크 숲코몽 알)
            Text(
              isEn ? '$parkName\'s Egg' : '$parkName 숲코몽 알',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 서브 타이틀 (시안 문구 반영)
            Text(
              isEn
                  ? 'A egg has appeared in $parkName!\nWalk together so it can hatch!'
                  : '$parkName에 숲코몽 알이 나타났어요!\n숲코몽이 태어날 수 있도록 같이 걸어주세요!',
              style: AppTextStyles.body.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 하단 풀 너비 '획득하기' 버튼
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(homeViewModelProvider.notifier).clearAcquiredPet();
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary700,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isEn ? 'Acquire' : '획득하기',
                  style: AppTextStyles.subTitleL,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
