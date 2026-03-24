import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

class PetHatchedDialog extends ConsumerWidget {
  final String petName;
  final String parkName;
  final String imagePath;
  final bool isEn;

  const PetHatchedDialog({
    super.key,
    required this.petName,
    required this.parkName,
    required this.imagePath,
    required this.isEn,
  });

  static Future<void> show(
    BuildContext context, {
    required String petName,
    required String parkName,
    required String imagePath,
    required bool isEn,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PetHatchedDialog(
        petName: petName,
        parkName: parkName,
        imagePath: imagePath,
        isEn: isEn,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            SoopkomonImage(
              assetPath: imagePath,
              remoteUrl:
                  'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/characters%2F${imagePath.split('/').last.split('_').first}_big.png?alt=media',
              width: 112,
              height: 112,
            ),
            const SizedBox(height: 20),
            Text(
              isEn ? '$parkName $petName' : '$parkName $petName',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 서브 타이틀 (시안 문구 반영)
            Text(
              isEn
                  ? '$petName has hatched from $parkName!\nCheck the encyclopedia for details!'
                  : '$parkName에 $petName 숲코몽이 태어났어요!\n도감에서 자세한 정보를 확인하세요!',
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
