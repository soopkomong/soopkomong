import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class SendFriendRequestSection extends ConsumerStatefulWidget {
  const SendFriendRequestSection({super.key});

  @override
  ConsumerState<SendFriendRequestSection> createState() =>
      _SendFriendRequestSectionState();
}

class _SendFriendRequestSectionState
    extends ConsumerState<SendFriendRequestSection> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final value = _idController.text.trim();
    if (value.isEmpty) return;

    final locale = ref.read(localeProvider);
    final isEn = locale == AppLocale.en;

    try {
      await ref
          .read(friendsViewModelProvider.notifier)
          .sendFriendRequest(value);
      _idController.clear();

      if (!mounted) return;
      FocusScope.of(context).unfocus();

      _showResultDialog(isEn ? 'Friend request sent.' : '친구 요청을 보냈습니다.', isEn);
    } catch (e) {
      if (!mounted) return;

      final errorMsg = isEn
          ? (e.toString().contains('already')
                ? 'Wait for response or check your friend list.'
                : 'Invalid code or error occurred.')
          : e.toString().replaceAll('Exception: ', '');

      _showResultDialog(errorMsg, isEn);
    }
  }

  void _showResultDialog(String message, bool isEn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEn ? 'OK' : '확인',
              style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            isEn ? 'Send Friend Request' : '친구 요청 보내기',
            style: AppTextStyles.subTitleM,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gray50, // 매우 연한 회색 배경
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.gray300, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _idController,
                  onChanged: (value) => setState(() {}), // send icon visibility
                  onSubmitted: (_) => _sendRequest(),
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: isEn ? 'Enter friend ID' : '친구 ID를 입력해주세요',
                    hintStyle: AppTextStyles.body,
                    filled: true,
                    fillColor: AppColors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.subTitleL.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ),
              if (_idController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary600),
                  onPressed: _sendRequest,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
