import 'package:flutter/material.dart';

/// 개인정보처리방침 & 약관동의 링크 위젯
class PolicyLinks extends StatelessWidget {
  const PolicyLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showPolicyDialog(context, '개인정보처리방침', '개인정보처리방침 내용이 준비 중입니다.');
          },
          child: const Text(
            '개인정보처리방침',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF999999),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '|',
            style: TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
          ),
        ),
        GestureDetector(
          onTap: () {
            _showPolicyDialog(context, '약관동의', '이용약관 내용이 준비 중입니다.');
          },
          child: const Text(
            '약관동의',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }

  /// 정책, 약관 내용을 보여주는 바텀시트 다이얼로그
  void _showPolicyDialog(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 핸들 바
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 제목
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  // 내용
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
