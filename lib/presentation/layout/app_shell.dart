import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/home/widgets/friend_request_dialog.dart';
import 'package:soopkomong/presentation/home/widgets/welcome_back_dialog.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/widgets/app_bottom_nav_bar.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {


  @override
  Widget build(BuildContext context) {

    // 탭 진입 전 미리 로드 (collection 탭 shimmer 방지)
    ref.watch(locationsProvider);
    ref.watch(soopkomonTemplatesProvider);

    // 실시간 친구 요청 리스닝
    ref.listen(friendRequestProvider, (previous, next) {
      if (next is AsyncData && next.value!.isNotEmpty) {
        // 아직 알림이 노출되지 않은 요청(notified == false)에 대해서만 팝업 노출
        for (final request in next.value!) {
          if (!request.notified) {
            FriendRequestDialog.show(
              context,
              nickname: request.senderName,
              isEn: ref.read(localeProvider) == AppLocale.en,
              onConfirm: () {
                ref.read(friendsViewModelProvider.notifier).markNotified(request.id);
              },
            );
          }
        }
      }
    });

    // 재로그인 환영 팝업 리스닝
    ref.listen(userProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        final user = next.value!;
        if (user.wasReentry) {
          WelcomeBackDialog.show(
            context,
            onConfirm: () {
              ref.read(authRepositoryProvider).clearReentryFlag();
            },
          );
        }
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            widget.navigationShell,
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AppBottomNavigationBar(navigationShell: widget.navigationShell),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
