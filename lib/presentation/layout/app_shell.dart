import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
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
  // 이미 표시된 친구 요청 ID를 추적하여 중복 팝업 방지
  final Set<String> _shownRequestIds = {};

  void _showFriendRequestDialog(BuildContext context, WidgetRef ref, dynamic request) {
    // 이미 보여준 요청이면 스킵
    if (_shownRequestIds.contains(request.id)) return;
    
    _shownRequestIds.add(request.id);

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
    // 탭 진입 전 미리 로드 (collection 탭 shimmer 방지)
    ref.watch(locationsProvider);
    ref.watch(soopkomonTemplatesProvider);

    // 실시간 친구 요청 리스닝
    ref.listen(friendRequestProvider, (previous, next) {
      if (next is AsyncData && next.value!.isNotEmpty) {
        // 모든 새로운 요청에 대해 팝업을 띄울 수 있도록 함
        for (final request in next.value!) {
          if (!_shownRequestIds.contains(request.id)) {
            _showFriendRequestDialog(context, ref, request);
          }
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
