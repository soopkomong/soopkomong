import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/widgets/app_bottom_nav_bar.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  void _showFriendRequestDialog(BuildContext context, WidgetRef ref, FriendRequest request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '친구 요청',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${request.senderName}님이 친구 요청을 했습니다.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '친구 수락은 친구 목록에서 확인하실 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              // 알림 확인 처리 (Firestore 업데이트)
              ref.read(friendsViewModelProvider.notifier).markNotified(request.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary700,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showWelcomeBackDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '반가워요!',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '다시 돌아오셨군요!\n기존에 모았던 도감과 기록들은\n그대로 안전하게 보관되어 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              '자, 이제 남은 모험을 다시 즐겨볼까요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 재진입 플래그 초기화
                  ref.read(authRepositoryProvider).clearReentryFlag();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary700,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '좋아요!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            _showFriendRequestDialog(context, ref, request);
          }
        }
      }
    });

    // 재로그인 환영 팝업 리스닝
    ref.listen(userProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        final user = next.value!;
        if (user.wasReentry) {
          _showWelcomeBackDialog(context, ref);
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
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AppBottomNavigationBar(navigationShell: widget.navigationShell),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
