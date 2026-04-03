import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/constants/assets.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_shadows.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class AppBottomNavigationBar extends ConsumerStatefulWidget {
  const AppBottomNavigationBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppBottomNavigationBar> createState() =>
      _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState
    extends ConsumerState<AppBottomNavigationBar> {
  void _onTap(int index) {
    if (index == 0 && widget.navigationShell.currentIndex != 0) {
      // 다른 탭에서 홈 탭으로 이동할 때 줌 초기화 트리거
      ref.read(mapZoomResetProvider.notifier).triggerReset();
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    final labels = isEn
        ? ['Home', 'Collection', 'Parks', 'Friends']
        : ['홈', '도감', '생태공원', '친구'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 357),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: ShapeDecoration(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(70),
              ),
              shadows: AppShadows.elevated,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(labels.length, (index) {
                final isSelected = currentIndex == index;

                final iconPaths = isSelected
                    ? [
                        Assets.homeFill,
                        Assets.notebookFill,
                        Assets.globeFill,
                        Assets.usersFill
                      ]
                    : [
                        Assets.homeLine,
                        Assets.notebookLine,
                        Assets.globeLine,
                        Assets.usersLine
                      ];

                final iconPath = iconPaths[index];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: AppColors.transparent,
                      child: AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              iconPath,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.primary700
                                    : AppColors.gray400,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[index],
                              style: AppTextStyles.label.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.primary700
                                    : AppColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
