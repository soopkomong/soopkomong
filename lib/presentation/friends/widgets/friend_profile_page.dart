import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/domain/entities/location.dart';

class FriendProfilePage extends ConsumerWidget {
  const FriendProfilePage({super.key, required this.friend});

  final FriendModel friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('yyyy년 M월 d일');
    final numberFormat = NumberFormat('#,###');

    final friendsAsync = ref.watch(friendsViewModelProvider);
    final isFriend = friendsAsync.value?.any((f) => f.id == friend.id) ?? false;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isFriend)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.black),
              onPressed: () => _showDeleteDialog(context, ref),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 캐릭터 이미지 및 기본 정보
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/characters/${friend.characterTemplateId}_big.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: AppColors.gray50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 80, color: AppColors.gray300),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        friend.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. 정보 카드 (친구 된 날, 총 걸음 수)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray100),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      isFriend ? '친구 가 된 날' : '요청 받은 날', 
                      dateFormat.format(friend.friendedAt ?? DateTime.now()),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('총 걸음 수', numberFormat.format(friend.totalSteps)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: AppColors.gray50),
            const SizedBox(height: 24),

            // 3. 진행도 배지 섹션
            _buildProgressBadges(ref),

            const SizedBox(height: 24),

            // 4. 생태공원 리스트
            _buildSectionTitle('생태공원'),
            const SizedBox(height: 12),
            _buildHorizontalParkList(ref),

            const SizedBox(height: 24),

            // 5. 숲코몽 리스트
            _buildSectionTitle('숲코몽'),
            const SizedBox(height: 12),
            _buildHorizontalSoopkomongList(ref),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ':  ',
          style: TextStyle(fontSize: 14, color: AppColors.gray600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  Widget _buildProgressBadges(WidgetRef ref) {
    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));

    return friendCharactersAsync.when(
      data: (characters) {
        final visitedCount = characters
            .map((c) => c.discoveredSpotId)
            .where((id) => id.isNotEmpty)
            .toSet()
            .length;
        final collectedCount = characters.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressBadge(
                icon: Icons.eco,
                color: AppColors.secondaryGreen,
                current: visitedCount,
                total: friend.leafMax,
              ),
              const SizedBox(width: 12),
              _buildProgressBadge(
                icon: Icons.pets,
                color: AppColors.black,
                current: collectedCount,
                total: friend.pawMax,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 36), // 로딩 중 높이 유지
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressBadge({
    required IconData icon,
    required Color color,
    required int current,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF3), // 연한 초록빛 배경
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$current/$total',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildHorizontalParkList(WidgetRef ref) {
    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));
    final locationsAsync = ref.watch(locationsProvider);

    return friendCharactersAsync.when(
      data: (characters) {
        // 획득한 캐릭터들의 발견 장소 ID 세트 (중복 제거)
        final visitedSpotIds = characters
            .map((c) => int.tryParse(c.discoveredSpotId) ?? -1)
            .where((id) => id != -1)
            .toSet();

        if (visitedSpotIds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('방문한 생태공원이 없습니다.', style: TextStyle(color: AppColors.gray400)),
          );
        }

        return locationsAsync.when(
          data: (allLocations) {
            // 전체 공원 중 친구가 방문한 공원만 필터링 (중복 제거)
            final uniqueMap = <int, Location>{};
            for (var loc in allLocations) {
              if (visitedSpotIds.contains(loc.id)) {
                uniqueMap[loc.id] = loc;
              }
            }
            final visitedLocations = uniqueMap.values.toList();

            return SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: visitedLocations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final park = visitedLocations[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                          image: park.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(park.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage('assets/images/park_placeholder.png'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 120,
                        child: Text(
                          park.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          park.address,
                          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text('공원 정보 로드 실패')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('방문 정보 로드 실패')),
    );
  }

  Widget _buildHorizontalSoopkomongList(WidgetRef ref) {
    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));

    return friendCharactersAsync.when(
      data: (characters) {
        if (characters.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('획득한 숲코몽이 없습니다.', style: TextStyle(color: AppColors.gray400)),
          );
        }
        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: characters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final character = characters[index];
              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        character.imagePath,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.pets, color: AppColors.gray300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    character.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('데이터 로드 실패')),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 삭제'),
        content: Text('${friend.name}님을 친구 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.gray500)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(friendsViewModelProvider.notifier).removeFriend(friend.id);
              if (context.mounted) {
                Navigator.pop(context); // 다이얼로그 닫기
                context.pop(); // 프로필 페이지 닫기
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
