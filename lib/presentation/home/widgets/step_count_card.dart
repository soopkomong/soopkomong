import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';

class StepCountCard extends StatelessWidget {
  final HomeState state;
  final bool isEn;

  const StepCountCard({
    super.key,
    required this.state,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isEn ? "Today's Steps" : "오늘 걸음 수",
            style: const TextStyle(
              color: Color(0xFF191919),
              fontSize: 12,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              height: 1.40,
              letterSpacing: 0.12,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/footprints.svg",
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.orange,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                state.stepCount.toString(),
                style: const TextStyle(
                  color: Color(0xFF191919),
                  fontSize: 24,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
