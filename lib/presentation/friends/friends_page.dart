import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/router/app_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_shadows.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/friend_request_provider.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/domain/entities/friend_request.dart';
import 'package:soopkomong/presentation/friends/widgets/friend_list_item.dart';
import 'package:soopkomong/presentation/friends/widgets/send_friend_request_section.dart';
import 'package:soopkomong/presentation/widgets/url_avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({super.key});

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _navigateToProfile(
    BuildContext context,
    WidgetRef ref,
    FriendRequest request,
  ) async {
    // 로딩 다이얼로그 표시 (rootNavigator 사용하여 전역적으로 띄움)
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary700),
      ),
    );

    try {
      final friendModel = await ref
          .read(friendsViewModelProvider.notifier)
          .getFriendModelByUserId(request.senderId);

      if (context.mounted) {
        // 로딩 다이얼로그 닫기 (명시적으로 rootNavigator에서 pop)
        Navigator.of(context, rootNavigator: true).pop();

        context.pushNamed(AppRoute.friendProfile.name, extra: friendModel);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필 로드 실패: $e')));
      }
    }
  }

  void _showCopySuccessDialog(BuildContext context, bool isEn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actionsAlignment: MainAxisAlignment.center,
        content: Text(
          isEn ? 'Code copied to clipboard.' : '코드가 클립보드에 복사되었습니다.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEn ? 'OK' : '확인',
              style: const TextStyle(color: AppColors.primary700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String label,
    required int count,
    required bool isEn,
  }) {
    final title = isEn ? '$label : $count' : '$label : $count명';
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/Users_Fill.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.subTitleM.copyWith(color: AppColors.gray900),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;
    final friendsAsync = ref.watch(friendsViewModelProvider);
    final friendRequestsAsync = ref.watch(friendRequestProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people),
            SizedBox(width: 8),
            Text(isEn ? 'Friends' : '친구목록'),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                // 내 ID 카드
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.gray900,
                          ),
                          children: [
                            TextSpan(text: isEn ? 'My Code : ' : '내 코드 : '),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text:
                                  ref.watch(userProvider).value?.userCode ??
                                  '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          final userCode =
                              ref.read(userProvider).value?.userCode;
                          if (userCode == null) return;

                          Clipboard.setData(ClipboardData(text: userCode));
                          _showCopySuccessDialog(context, isEn);
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 18,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 친구 요청 보내기
                const SendFriendRequestSection(),
              ]),
            ),
          ),
          // 친구 신청 목록
          friendRequestsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader(
                      label: isEn ? 'Friend Requests' : '친구 신청 목록',
                      count: requests.length,
                      isEn: isEn,
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AppColors.gray50, height: 1),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _navigateToProfile(context, ref, request),
                                child: UrlAvatar(
                                  photoUrl: request.senderPhotoUrl ?? '',
                                  size: 60,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _navigateToProfile(
                                        context,
                                        ref,
                                        request,
                                      ),
                                      child: Text(
                                        request.senderName,
                                        style: AppTextStyles.subTitleL.copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: friendsAsync.isLoading
                                              ? null
                                              : () async {
                                                  try {
                                                    await ref
                                                        .read(
                                                          friendsViewModelProvider
                                                              .notifier,
                                                        )
                                                        .acceptFriendRequest(
                                                          request,
                                                        );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            '친구 요청을 수락했습니다.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '수락 실패: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: friendsAsync.isLoading
                                                  ? AppColors.gray300
                                                  : AppColors.primary700,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              isEn ? 'Accept' : '승인',
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: friendsAsync.isLoading
                                              ? null
                                              : () async {
                                                  try {
                                                    await ref
                                                        .read(
                                                          friendsViewModelProvider
                                                              .notifier,
                                                        )
                                                        .declineFriendRequest(
                                                          request.id,
                                                        );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            '친구 요청을 거절했습니다.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '거절 실패: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.gray100,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              isEn ? 'Decline' : '거절',
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                    color:
                                                        friendsAsync.isLoading
                                                        ? AppColors.gray300
                                                        : AppColors.gray600,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ]),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, st) => SliverToBoxAdapter(
              child: Center(
                child: Text(
                  isEn ? 'Error loading requests: $e' : '친구 신청 로드 오류: $e',
                  style: AppTextStyles.label.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ),
          // 내 친구 목록 헤더
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSectionHeader(
                    label: isEn ? 'My Friends' : '내 친구',
                    count: friendsAsync.value?.length ?? 0,
                    isEn: isEn,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 친구 리스트
          friendsAsync.when(
            data: (friends) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index.isOdd) {
                    return const Divider(color: AppColors.gray50, height: 1);
                  }
                  final itemIndex = index ~/ 2;
                  return FriendListItem(friend: friends[itemIndex]);
                }, childCount: friends.isEmpty ? 0 : friends.length * 2 - 1),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Text(isEn ? 'Error occurred: $e' : '오류 발생: $e'),
              ),
            ),
          ),
          // 하단 네비게이션 바 공간 확보를 위한 여백
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
