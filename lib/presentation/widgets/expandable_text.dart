import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class ExpandableText extends ConsumerStatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 4,
    this.style,
  });

  @override
  ConsumerState<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends ConsumerState<ExpandableText>
    with TickerProviderStateMixin {
  bool _expanded = false;
  bool _showButton = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfOverflow();
  }

  void _checkIfOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 64);

    _showButton = textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.text
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n');
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: AppTextStyles.body.copyWith(color: AppColors.gray900),
            maxLines: _expanded ? null : widget.trimLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),

          if (_showButton) ...[
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded
                          ? (ref.watch(localeProvider) == AppLocale.en
                                ? 'Collapse'
                                : '내용 접기')
                          : (ref.watch(localeProvider) == AppLocale.en
                                ? 'Read more'
                                : '더보기'),
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
