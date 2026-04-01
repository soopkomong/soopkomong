import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/widgets/character_avatar.dart';
import 'package:soopkomong/presentation/friends/widgets/friend_park_section.dart';
import 'package:soopkomong/presentation/friends/widgets/friend_soopkomong_section.dart';

import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/widgets/common_back_button.dart';
import 'package:soopkomong/presentation/friends/widgets/friend_delete_dialog.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class FriendProfilePage extends ConsumerWidget {
  const FriendProfilePage({super.key, required this.friend});

  final FriendModel friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    final dateFormat = isEn
        ? DateFormat.yMMMd('en')
        : DateFormat('yyyy년 M월 d일');
    final numberFormat = NumberFormat('#,###');

    final friendsAsync = ref.watch(friendsViewModelProvider);
    final isFriend = friendsAsync.value?.any((f) => f.id == friend.id) ?? false;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: CommonBackButton(),
        ),
        actions: [
          if (isFriend)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gray100),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: SvgPicture.asset(
                    'assets/images/trash.svg',
                    width: 20,
                    height: 20,
                  ),
                  onPressed: () => _showDeleteDialog(context, ref),
                ),
              ),
            ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 캐릭터 전신 이미지는 중앙 정렬
                  Center(
                    child: CharacterAvatar(
                      characterSettings: friend.characterSettings,
                      size: 250,
                      useCircle: false,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 사용자 이름은 좌측 정렬
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(friend.name, style: AppTextStyles.subTitleL),
                  ),

                  // 2. 정보 카드 (좌측 정렬 배치)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            isFriend
                                ? (isEn ? 'Friended at' : '친구가 된 날')
                                : (isEn ? 'Requested at' : '요청 받은 날'),
                            dateFormat.format(
                              friend.friendedAt ?? DateTime.now(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            isEn ? 'Total Steps' : '총 걸음 수',
                            numberFormat.format(friend.totalSteps),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 3, color: AppColors.gray50),
            const SizedBox(height: 24),

            // 3. 진행도 배지 섹션
            _buildProgressBadges(ref),

            const SizedBox(height: 8),

            // 4. 생태공원 리스트
            FriendParkSection(friend: friend),
            const SizedBox(height: 16),
            // 5. 숲코몽 리스트
            FriendSoopkomongSection(friend: friend),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.body),
        SizedBox(width: 10),
        const Text(':  ', style: AppTextStyles.body),
        SizedBox(width: 10),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }

  Widget _buildProgressBadges(WidgetRef ref) {
    final friendCharactersAsync = ref.watch(friendSoopkomonProvider(friend.id));
    final totalLocationsAsync = ref.watch(totalLocationsCountProvider);
    final totalTemplatesAsync = ref.watch(totalTemplatesCountProvider);

    return friendCharactersAsync.when(
      data: (characters) {
        final visitedCount = characters
            .map((c) => c.discoveredSpotId)
            .where((id) => id.isNotEmpty)
            .toSet()
            .length;
        final collectedCount = characters.length;

        final leafMax = totalLocationsAsync.value ?? 50;
        final pawMax = totalTemplatesAsync.value ?? 30;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressBadge(
                iconWidget: SvgPicture.asset(
                  'assets/images/Leaf.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
                current: visitedCount,
                total: leafMax,
              ),
              const SizedBox(width: 8),
              _buildProgressBadge(
                iconWidget: Image.asset(
                  'assets/images/Sprout.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
                current: collectedCount,
                total: pawMax,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 36),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildProgressBadge({
    required Widget iconWidget,
    required int current,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 8),
          Text('$current/$total', style: AppTextStyles.label),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => FriendDeleteDialog(friend: friend),
    );
  }
}
