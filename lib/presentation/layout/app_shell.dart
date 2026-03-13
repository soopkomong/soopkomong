import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/presentation/friends/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/widgets/app_bottom_nav_bar.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _showFriendRequestDialog(BuildContext context, WidgetRef ref, dynamic request) {
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
        content: Text(
          '${request.senderName}님이 친구 요청을 했습니다.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () async {
              await ref
                  .read(friendsViewModelProvider.notifier)
                  .declineFriendRequest(request.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.gray500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(friendsViewModelProvider.notifier)
                  .acceptFriendRequest(request);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary700,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실시간 친구 요청 리스닝
    ref.listen(friendRequestProvider, (previous, next) {
      if (next is AsyncData && next.value!.isNotEmpty) {
        // 가장 최근 요청 하나만 표시 (여러 개가 동시에 올 경우를 대비해 로직 개선 가능)
        final latestRequest = next.value!.last;
        
        // 이전 데이터와 비교하여 정말 새로운 요청인지 확인 (간단하게 ID 비교)
        final previousIds = previous?.value?.map((r) => r.id).toSet() ?? {};
        if (!previousIds.contains(latestRequest.id)) {
           _showFriendRequestDialog(context, ref, latestRequest);
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavigationBar(navigationShell: navigationShell),
            ),
          ),
        ],
      ),
    );
  }
}
