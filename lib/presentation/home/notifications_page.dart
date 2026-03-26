import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/home/widgets/notification_tile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final friendRequestsAsync = ref.watch(friendRequestHistoryProvider);
    final requests = friendRequestsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEn ? 'Notifications' : '알림',
          style: AppTextStyles.title.copyWith(letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // 실제 친구 요청 목록
          if (requests.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  isEn ? 'No more notifications.' : '더 이상의 알림이 없습니다.',
                  style: AppTextStyles.body.copyWith(color: AppColors.gray400),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Slidable(
                      key: ValueKey(req.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              ref
                                  .read(friendsViewModelProvider.notifier)
                                  .deleteNotification(req.id);
                              _showSnackBar(
                                context,
                                isEn ? 'Deleted.' : '삭제되었습니다.',
                              );
                            },
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: isEn ? 'Delete' : '삭제',
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ],
                      ),
                      child: NotificationTile(
                        title: isEn ? 'Friend Request' : '친구 신청',
                        subtitle: isEn
                            ? '${req.senderName} sent you a friend request.'
                            : '${req.senderName}님이 친구 신청을 보냈습니다.',
                        date: req.formattedTimestamp,
                        type: NotificationType.friendRequest,
                        characterTemplateId: req.senderTemplateId,
                        avatarUrl: req.senderPhotoUrl,
                        margin: EdgeInsets.zero,
                        statusText: req.status == FriendRequestStatus.pending
                            ? null
                            : (req.status == FriendRequestStatus.accepted
                                  ? (isEn ? 'Accepted' : '수락됨')
                                  : (isEn ? 'Declined' : '거절됨')),
                      ),
                    ),
                  );
                }, childCount: requests.length),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.gray800,
      ),
    );
  }
}
