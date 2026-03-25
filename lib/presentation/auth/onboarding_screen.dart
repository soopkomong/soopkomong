import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'package:soopkomong/core/theme/app_text_styles.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/presentation/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: '공원에 가야 숲코몽 알을 발견할 수 있어요',
      description: '생태공원에 도착하는 순간,\n숲코몽 알이 기다리고 있어요!',
      imagePath: 'assets/images/onboarding/01.png',
      backgroundColor: AppColors.primary100,
    ),
    OnboardingItem(
      title: '함께 걸으면 숲코몽이 태어나요',
      description: '알을 품고 일정 걸음 이상 걸으면\n숲코몽이 깨어나요!',
      imagePath: 'assets/images/onboarding/02.png',
      backgroundColor: AppColors.primary100,
    ),
    OnboardingItem(
      title: '내가 가본 공원도 숲코몽도 모두 기록돼요',
      description: '도감에서 나만의 탐험 기록을 확인해요!',
      imagePath: 'assets/images/onboarding/03.png',
      backgroundColor: AppColors.primary100,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == _items.length - 1;

    // 강제로 상태바 아이콘을 어둡게 설정 (iOS/Android 공통)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 상단 캐릭터 영역 (배경색 포함)
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: _items[index].backgroundColor,
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40.0,
                              ),
                              child: Image.asset(
                                _items[index].imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 하단 텍스트 및 조작 영역
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      _items[_currentPage].title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subTitleL.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _items[_currentPage].description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray500,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),

                    // 페이지 인디케이터
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppColors.gray600
                                : AppColors.gray200,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32), // 인디케이터와 버튼 사이 고정 간격
                    // 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isLastPage) {
                            await ref
                                .read(onboardingProvider.notifier)
                                .completeOnboarding();
                            if (mounted) {
                              context.go(AppRoute.signIn.path);
                            }
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(
                                milliseconds: 350,
                              ), // 애니메이션 속도 약간 조절
                              curve: Curves.easeOutCubic, // 더 부드러운 곡선
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLastPage ? '시작하기' : '다음',
                          style: AppTextStyles.subTitleL.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 로그인 링크
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '이미 계정이 있으신가요? 바로 ',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoute.signIn.path);
                          },
                          child: Text(
                            '로그인하세요',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48), // 하단바 영역 확보를 위한 넉넉한 여백
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}
