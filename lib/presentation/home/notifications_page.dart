import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final friendRequestsAsync = ref.watch(friendRequestHistoryProvider);
    final requests = friendRequestsAsync.value ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEn ? 'Notifications' : '알림',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: requests.isEmpty
          ? Center(
              child: Text(
                isEn ? 'No new notifications.' : '새로운 알림이 없습니다.',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final req = requests[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.gray50,
                    backgroundImage: AssetImage(
                      'assets/images/characters/${req.senderTemplateId}_big.png',
                    ),
                  ),
                  title: Text(
                    isEn ? 'Friend Request' : '친구 신청',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isEn ? '${req.senderName} sent you a friend request.' : '${req.senderName}님이 친구 신청을 보냈습니다.',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        req.formattedTimestamp,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      if (req.status == FriendRequestStatus.pending) ...[
                        TextButton(
                          onPressed: () {
                            ref
                                .read(friendsViewModelProvider.notifier)
                                .acceptFriendRequest(req);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEn ? 'Friend request accepted.' : '친구 신청을 수락했습니다.')),
                            );
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF48B200),
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text(isEn ? 'Accept' : '수락',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(friendsViewModelProvider.notifier)
                                .declineFriendRequest(req.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEn ? 'Friend request declined.' : '친구 신청을 거절했습니다.')),
                            );
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text(isEn ? 'Decline' : '거절'),
                        ),
                      ] else ...[
                        Text(
                          req.status == FriendRequestStatus.accepted 
                            ? (isEn ? 'Accepted' : '수락됨') 
                            : (isEn ? 'Declined' : '거절됨'),
                          style: TextStyle(
                            fontSize: 12,
                            color: req.status == FriendRequestStatus.accepted
                                ? const Color(0xFF48B200)
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
