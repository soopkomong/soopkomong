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
    ),
    OnboardingItem(
      title: '함께 걸으면 숲코몽이 태어나요',
      description: '알을 품고 일정 걸음 이상 걸으면\n숲코몽이 깨어나요!',
      imagePath: 'assets/images/onboarding/02.png',
    ),
    OnboardingItem(
      title: '내가 가본 공원도 숲코몽도 모두 기록돼요',
      description: '도감에서 나만의 탐험 기록을 확인해요!',
      imagePath: 'assets/images/onboarding/03.png',
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 상단 페이지 인디케이터
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
                          ? AppColors.gray500
                          : AppColors.gray200,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(height: 48),
                        // 타이틀
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            _items[index].title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subTitleL.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 설명
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            _items[index].description,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body,
                          ),
                        ),
                        //Spacer를 활용해 이미지를 최대한 버튼 쪽으로 밀되, 오버플로우 방지
                        const Spacer(),
                        // 메인 이미지 영역
                        Expanded(
                          flex: 12,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Image.asset(
                              _items[index].imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),

              // 하단 버튼 영역 (바닥으로 최대한 밀착)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          debugPrint(
                            'DEBUG: 온보딩 버튼 클릭. 현재 페이지: $_currentPage, 마지막 페이지 여부: $isLastPage',
                          );
                          if (isLastPage) {
                            debugPrint(
                              'DEBUG: 온보딩 완료 처리 시작...',
                            );
                            await ref
                                .read(onboardingProvider.notifier)
                                .completeOnboarding();
                            debugPrint(
                              'DEBUG: 온보딩 완료 처리 대기(await) 종료.',
                            );

                            // onboardingProvider 상태 변화로 인해 GoRouter가 자동 리다이렉트하겠지만,
                            // 명시적으로 이동하여 더 빠른 사용자 피드백을 제공합니다.
                            if (!context.mounted) return;
                            debugPrint(
                              'DEBUG: context.go를 통해 로그인 페이지로 이동 시도',
                            );
                            context.go(AppRoute.signIn.path);
                          } else {
                            debugPrint('DEBUG: 온보딩 다음 페이지로 애니메이션 이동.');
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLastPage ? '시작하기' : '다음',
                          style: AppTextStyles.subTitleL.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                            style: AppTextStyles.subTitleM.copyWith(
                              color: AppColors.primary700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
