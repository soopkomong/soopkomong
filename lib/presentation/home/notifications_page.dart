import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendRequestsAsync = ref.watch(friendRequestProvider);
    final requests = friendRequestsAsync.value ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: requests.isEmpty
          ? const Center(
              child: Text(
                '새로운 알림이 없습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final req = requests[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF48B200),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    '${req.senderName}님이 친구 신청을 보냈습니다.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    '${req.timestamp.month}월 ${req.timestamp.day}일',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: req.status == FriendRequestStatus.pending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(friendsViewModelProvider.notifier)
                                    .acceptFriendRequest(req);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('친구 신청을 수락했습니다.')),
                                );
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF48B200)),
                              child: const Text('수락',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(friendsViewModelProvider.notifier)
                                    .declineFriendRequest(req.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('친구 신청을 거절했습니다.')),
                                );
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('거절'),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            req.status == FriendRequestStatus.accepted
                                ? '수락함'
                                : '거절함',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                );
              },
            ),
    );
  }
}
