import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
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
            onPressed: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실시간 친구 요청 리스닝
    ref.listen(friendRequestProvider, (previous, next) {
      if (next is AsyncData && next.value!.isNotEmpty) {
        // 가장 최근 요청 하나만 표시
        final latestRequest = next.value!.first;
        
        // 이전 데이터와 비교하여 정말 새로운 요청인지 확인 (간단하게 ID 비교)
        final previousIds = previous?.value?.map((r) => r.id).toSet() ?? {};
        if (!previousIds.contains(latestRequest.id)) {
           _showFriendRequestDialog(context, ref, latestRequest);
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
            navigationShell,
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AppBottomNavigationBar(navigationShell: navigationShell),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
