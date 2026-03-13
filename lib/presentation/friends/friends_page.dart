import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/presentation/friends/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/user_provider.dart';

class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({super.key});

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people, color: AppColors.black),
            const SizedBox(width: 8),
            const Text(
              '친구목록',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 내 ID 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.gray100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: '내 코드 : '),
                        TextSpan(
                          text: (ref.watch(userDocumentProvider).value?.data() as Map<String, dynamic>?)?['user_code'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final userCode = (ref.read(userDocumentProvider).value?.data() as Map<String, dynamic>?)?['user_code'];
                      if (userCode == null) return;
                      
                      // Clipboard: 텍스트 복사 기능
                      Clipboard.setData(ClipboardData(text: userCode));
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          content: const Text(
                            '코드가 클립보드에 복사되었습니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '확인',
                                style: TextStyle(color: AppColors.primary700),
                              ),
                            ),
                          ],
                        ),
                      );
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gray100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '친구 요청 보내기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _idController,
                            decoration: InputDecoration(
                              hintText: '친구 코드를 입력해주세요',
                              hintStyle: const TextStyle(
                                color: AppColors.gray400,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.gray400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (value) async {
                              if (value.isNotEmpty) {
                                await ref
                                    .read(friendsViewModelProvider.notifier)
                                    .addFriend(value);
                                _idController.clear();
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextButton(
                            onPressed: () async {
                              final value = _idController.text;
                              if (value.isNotEmpty) {
                                try {
                                  await ref
                                      .read(friendsViewModelProvider.notifier)
                                      .sendFriendRequest(value);
                                  _idController.clear();
                                  if (mounted) {
                                    FocusScope.of(context).unfocus();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        content: const Text(
                                          '친구 요청을 보냈습니다.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text(
                                              '확인',
                                              style: TextStyle(
                                                color: AppColors.primary700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                        actionsAlignment: MainAxisAlignment.center,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        content: Text(
                                          e.toString().replaceAll('Exception: ', ''),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text(
                                              '확인',
                                              style: TextStyle(
                                                color: AppColors.primary700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                        actionsAlignment: MainAxisAlignment.center,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primary700,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '보내기',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 내 친구 목록 헤더
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  '내 친구 : ${friendsAsync.value?.length ?? 0}명',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 친구 리스트
            friendsAsync.when(
              // 1. 데이터ㅓ 성공적으로 가져왔을때
              data: (friends) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friends.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.gray50, height: 1),
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.gray50,
                          backgroundImage: AssetImage(
                            'assets/images/characters/${friend.characterTemplateId}_big.png',
                          ),
                          onBackgroundImageError: (_, __) {
                            // 이미지 없을 때 폴백 처리는 생략 (기본 배경 유지)
                          },
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.eco,
                                  size: 14,
                                  color: AppColors.secondaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${friend.leafProgress}/${friend.leafMax}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.pets,
                                  size: 14,
                                  color: AppColors.black,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${friend.pawProgress}/${friend.pawMax}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              // 2. 데이터 불러오는 중일때
              loading: () => const Center(child: CircularProgressIndicator()),
              // 3. 오류 발생시
              error: (e, _) => Center(child: Text('오류 발생: $e')),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
