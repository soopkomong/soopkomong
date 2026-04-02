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
import 'package:soopkomong/core/utils/app_toast.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/widgets/app_bottom_nav_bar.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  String? _lastShownRequestId; // 중복 팝업 방지를 위한 변수

  @override
  Widget build(BuildContext context) {
    // 탭 진입 전 미리 로드 (collection 탭 shimmer 방지)
    ref.watch(locationsProvider);
    ref.watch(soopkomonTemplatesProvider);

    // 1. 초기 로드 시 또는 상태 변경 시 펜딩 요청 감지 (리스너가 작동하지 않는 초기 상태 대응)
    final currentRequests = ref.watch(friendRequestProvider).asData?.value;
    if (currentRequests != null && currentRequests.isNotEmpty) {
      final pending = currentRequests.where((req) => !req.notified).firstOrNull;
      if (pending != null && pending.id != _lastShownRequestId) {
        _lastShownRequestId = pending.id;
        debugPrint('[친구신청] 초기/상태체크 팝업 노출 시도: ${pending.senderName} (${pending.id})');
        
        Future.microtask(() {
          if (!context.mounted) return;
          _showFriendRequestDialog(context, ref, pending);
        });
      }
    }

    // 2. 실시간 변경 리스닝
    ref.listen(friendRequestProvider, (previous, next) {
      final requests = next.asData?.value;
      if (requests == null || requests.isEmpty) return;

      final pendingRequest = requests.where((req) => !req.notified).firstOrNull;
      if (pendingRequest == null) return;

      if (pendingRequest.id == _lastShownRequestId) return;

      _lastShownRequestId = pendingRequest.id;
      debugPrint('[친구신청] 리스너 팝업 노출 시도: ${pendingRequest.senderName} (${pendingRequest.id})');

      Future.microtask(() {
        if (!context.mounted) return;
        _showFriendRequestDialog(context, ref, pendingRequest);
      });
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
            isEn: ref.read(localeProvider) == AppLocale.en,
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
                  child: AppBottomNavigationBar(
                    navigationShell: widget.navigationShell,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendRequestDialog(BuildContext context, WidgetRef ref, FriendRequest request) {
    final isEn = ref.read(localeProvider) == AppLocale.en;
    // 팝업 노출 직전 알림 확인 처리 (중복 방지 핵심)
    ref.read(friendsViewModelProvider.notifier).markNotified(request.id);

    FriendRequestDialog.show(
      context,
      nickname: request.senderName,
      photoUrl: request.senderPhotoUrl,
      isEn: ref.read(localeProvider) == AppLocale.en,
      onConfirm: () async {
        try {
          await ref.read(friendsViewModelProvider.notifier).acceptFriendRequest(request);
        } catch (e) {
          if (context.mounted) {
            AppToast.show(context, isEn ? 'Failed to accept.' : '수락에 실패했습니다.');
          }
        }
      },
      onReject: () async {
        try {
          await ref.read(friendsViewModelProvider.notifier).declineFriendRequest(request.id);
        } catch (e) {
          if (context.mounted) {
            AppToast.show(context, isEn ? 'Failed to decline.' : '거절에 실패했습니다.');
          }
        }
      },
    );
  }
}
