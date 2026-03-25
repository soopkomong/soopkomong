import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';

class FriendDeleteDialog extends ConsumerWidget {
  const FriendDeleteDialog({super.key, required this.friend});

  final FriendModel friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent, // Material 3에서 푸른빛 도는 것을 방지
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '친구 삭제',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
      content: Text(
        '${friend.name}님을 친구 목록에서 삭제하시겠습니까?',
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.gray700,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            await ref
                .read(friendsViewModelProvider.notifier)
                .removeFriend(friend.id);
            if (context.mounted) {
              Navigator.pop(context); // 다이얼로그 닫기
              context.pop(); // 프로필 페이지 닫기
            }
          },
          child: const Text(
            '삭제',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
