import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';

/// 햄버거 메뉴 팝업을 띄우는 독립 함수
Future<void> showHamburgerMenu({
  required BuildContext context,
  required WidgetRef ref,
  required bool isEn,
}) async {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  final result = await showMenu<String>(
    context: context,
    position: position.shift(const Offset(0, 48)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.gray100, width: 1),
    ),
    color: AppColors.white.withValues(alpha: 0.6),
    elevation: 0,

    items: [
      PopupMenuItem<String>(
        value: 'mypage',
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.user,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.gray800,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isEn ? 'My Page' : '마이페이지',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.gray800,
              ),
            ),
          ],
        ),
      ),
      const PopupMenuDivider(height: 1, color: AppColors.gray200),
      PopupMenuItem<String>(
        value: 'settings',
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.settings,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.black87,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(isEn ? 'Settings' : '설정', style: AppTextStyles.body),
          ],
        ),
      ),
    ],
  );

  if (result == 'mypage') {
    if (!context.mounted) return;
    await context.pushNamed(AppRoute.mypage.name);
    ref.read(mapZoomResetProvider.notifier).triggerReset();
  } else if (result == 'settings') {
    if (!context.mounted) return;
    await context.pushNamed(AppRoute.settings.name);
  }
}
