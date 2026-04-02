import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/presentation/providers/soopkomon_provider.dart';
import 'package:soopkomong/presentation/providers/step_provider.dart';

class TutorialGuidePage extends ConsumerStatefulWidget {
  const TutorialGuidePage({super.key});

  @override
  ConsumerState<TutorialGuidePage> createState() => _TutorialGuidePageState();
}

class _TutorialGuidePageState extends ConsumerState<TutorialGuidePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _showSpeechBubble = false;
  String _speechText = '반가워요! 숲코몽의 세상에 오신 것을 환영해요!';

  final List<String> _eggSpeeches = [
    '반가워요!',
    '절 꾹 눌러보셨나요?',
    '빨리 부화해서 당신을 만나고 싶어요!',
    '걸음수를 채우면 제가 깨어날 수 있어요!',
    '우리는 곧 아주 친한 친구가 될 거예요!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 첫 인사 띄우기
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showMessage(0);
    });
  }

  void _showMessage(int index) {
    setState(() {
      _speechText = _eggSpeeches[index];
      _showSpeechBubble = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSpeechBubble = false;
        });
      }
    });
  }

  void _onEggTapped() {
    // 무작위 메시지 선택 (이전과 다른 메시지로)
    final nextIndex =
        (DateTime.now().millisecondsSinceEpoch % _eggSpeeches.length);
    _showMessage(nextIndex.toInt());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7FFF2), // Light green tint
              AppColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        '함께 탐험을 시작해볼까요? ✨',
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '생태공원에 방문하면 새로운 알을 얻을 수 있지만,\n처음 오신 당신을 위해 특별한 알을 준비했어요!',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray600,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      // 말풍선 + 튜토리얼 알 이미지 + 애니메이션
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Speech Bubble
                          Positioned(
                            top: -100,
                            child: AnimatedOpacity(
                              opacity: _showSpeechBubble ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: 250,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _speechText,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.gray800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          // Bubble tail
                          Positioned(
                            top: -60,
                            child: AnimatedOpacity(
                              opacity: _showSpeechBubble ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: CustomPaint(
                                painter: _TrianglePainter(AppColors.white),
                                size: const Size(15, 10),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: _onEggTapped,
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, -_animation.value),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Glow effect
                                      Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary100
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/images/egg/egg_tuto.png',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                               color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              color: AppColors.primary700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '열심히 걸으면 알이 부화할 거예요!',
                              style: AppTextStyles.subTitleM.copyWith(
                                color: AppColors.primary700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              // 하단 버튼 섹션
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary700,
                        Color(0xFF4CAF50), // Vibrant green
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary700.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = ref.read(userProvider).value;
                      if (user == null) return;

                      final repository = ref.read(soopkomonRepositoryProvider);
                      final stepRepository = ref.read(stepRepositoryProvider);
                      final currentTotal = await stepRepository.getTotalSteps();
                      
                      await repository.addSoopkomon(
                        user.id,
                        Soopkomon.tutorialEgg(currentTotal),
                      );

                      await ref.read(authRepositoryProvider).completeTutorial();

                      if (!context.mounted) return;
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '시작하기',
                      style: AppTextStyles.subTitleL.copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
