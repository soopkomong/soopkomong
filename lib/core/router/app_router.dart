import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/presentation/mypage/my_page.dart';
import 'package:soopkomong/presentation/mypage/profile_edit_page.dart';
import 'package:soopkomong/presentation/mypage/character_page/character_customize_page.dart';
import 'package:soopkomong/presentation/auth/sign_in_screen.dart';
import 'package:soopkomong/presentation/auth/onboarding_screen.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/presentation/home/home_page.dart';
import 'package:soopkomong/presentation/collection/collection_page.dart';
import 'package:soopkomong/presentation/explore/explore_page.dart';
import 'package:soopkomong/presentation/friends/friends_page.dart';
import 'package:soopkomong/presentation/friends/widgets/friend_profile_page.dart';
import 'package:soopkomong/domain/entities/friend_model.dart';
import 'package:soopkomong/presentation/layout/app_shell.dart';
import 'package:soopkomong/presentation/home/notifications_page.dart';
import 'package:soopkomong/presentation/settings/settings_page.dart';
import 'package:soopkomong/presentation/providers/onboarding_provider.dart';

import 'package:soopkomong/presentation/auth/name_setting_page.dart';
import 'package:soopkomong/presentation/auth/tutorial_guide_page.dart';

export 'app_route.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userAsync = ref.read(userProvider);
      final hasSeenOnboarding = ref.read(onboardingProvider);

      final matchedLocation = state.matchedLocation;
      final isLoggingIn = matchedLocation == AppRoute.signIn.path;
      final isOnboarding = matchedLocation == AppRoute.onboarding.path;
      final isCustomizing = matchedLocation == AppRoute.characterCustomize.path;
      final isNameSetting = matchedLocation == AppRoute.nameSetting.path;
      final isTutorial = matchedLocation == AppRoute.tutorialGuide.path;

      final user = userAsync.value;

      debugPrint(
        '디버그: [Router] 리다이렉트 시작 - 경로: $matchedLocation, 인증: ${authState.hasValue ? (authState.value != null ? "로그인됨" : "로그아웃됨") : "로딩중"}, 유저: ${user != null ? "데이터 있음" : (userAsync.isLoading ? "로딩중" : "데이터 없음")}',
      );

      // (A) 최우선: 유효한 유저 데이터가 확인된 경우 (로그인 성공)
      // 인증 스트림(authState)이 로딩 중이거나 일시적으로 null일 수 있으므로 user 데이터가 있다면 이를 최우선으로 신뢰함
      if (user != null) {
        if (isLoggingIn || isOnboarding) {
          debugPrint('디버그: [Router] 유저 데이터 확인됨. 홈으로 이동');
          return AppRoute.home.path;
        }
        // 단계별 설정 체크
        if (!user.hasCharacter) {
          if (isCustomizing) return null;
          return AppRoute.characterCustomize.path;
        }
        if (!user.hasName) {
          if (isNameSetting) return null;
          return AppRoute.nameSetting.path;
        }
        if (!user.hasSeenTutorial) {
          if (isTutorial) return null;
          return AppRoute.tutorialGuide.path;
        }
        if (isCustomizing || isNameSetting || isTutorial) {
          return AppRoute.home.path;
        }
        return null;
      }

      // (B) 온보딩 시청 여부 (로그인 전에 먼저 체크)
      if (!hasSeenOnboarding) {
        if (isOnboarding) return null;
        debugPrint('디버그: [Router] 온보딩 화면으로 이동');
        return AppRoute.onboarding.path;
      }

      // (C) 명확한 로그아웃 상태 확인 (인증 정보가 비워진 경우)
      if (authState.hasValue && authState.value == null) {
        if (isLoggingIn) return null;
        debugPrint('디버그: [Router] 인증 정보 없음. 로그인 화면으로 이동');
        return AppRoute.signIn.path;
      }

      // (D) 에러 발생 시 처리
      if (authState.hasError || userAsync.hasError) {
        debugPrint('디버그: [Router] 에러 발생. 로그인 화면으로 이동');
        if (isLoggingIn) return null;
        return AppRoute.signIn.path;
      }

      // (E) 정말 아무 것도 없는 초기 로딩 상태 대기
      if (userAsync.isLoading || authState.isLoading) {
        debugPrint('디버그: [Router] 초기 로딩 중... $matchedLocation 대기');
        return null;
      }

      debugPrint('디버그: [Router] 최종 가드 통과. 경로: $matchedLocation');
      return null;
    },
    observers: [routeObserver],

    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.collection.path,
                name: AppRoute.collection.name,
                builder: (context, state) {
                  final tab =
                      int.tryParse(state.uri.queryParameters['tab'] ?? '0') ??
                      0;
                  return CollectionPage(initialTab: tab);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.explore.path,
                name: AppRoute.explore.name,
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.friends.path,
                name: AppRoute.friends.name,
                builder: (context, state) => const FriendsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.friendProfile.path,
        name: AppRoute.friendProfile.name,
        builder: (context, state) {
          final friend = state.extra as FriendModel?;
          if (friend == null) {
            return const Scaffold(body: Center(child: Text('정보를 불러올 수 없습니다.')));
          }
          return FriendProfilePage(friend: friend);
        },
      ),
      GoRoute(
        path: AppRoute.mypage.path,
        name: AppRoute.mypage.name,
        builder: (context, state) => const MyPage(),
      ),
      GoRoute(
        path: AppRoute.profileEdit.path,
        name: AppRoute.profileEdit.name,
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: AppRoute.characterCustomize.path,
        name: AppRoute.characterCustomize.name,
        builder: (context, state) => const CharacterCustomizePage(),
      ),
      GoRoute(
        path: AppRoute.notifications.path,
        name: AppRoute.notifications.name,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoute.nameSetting.path,
        name: AppRoute.nameSetting.name,
        builder: (context, state) => const NameSettingPage(),
      ),
      GoRoute(
        path: AppRoute.tutorialGuide.path,
        name: AppRoute.tutorialGuide.name,
        builder: (context, state) => const TutorialGuidePage(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoute.signIn.path,
        name: AppRoute.signIn.name,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});

/// 라우터 리프레시를 관리하는 Notifier
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // 인증 상태 변화 감시
    _ref.listen(authStateChangesProvider, (prev, next) {
      debugPrint('디버그: [RouterNotifier] 인증 상태 변경 감지');
      notifyListeners();
    }, fireImmediately: true); // 즉시 실행하여 초기 상태 반영 보장

    // 유저 데이터 변화 감시
    _ref.listen(userProvider, (prev, next) {
      debugPrint('디버그: [RouterNotifier] 유저 데이터 변경 감지');
      notifyListeners();
    }, fireImmediately: true);

    // 온보딩 상태 변화 감시
    _ref.listen(onboardingProvider, (prev, next) {
      debugPrint('디버그: [RouterNotifier] 온보딩 상태 변경 감지');
      notifyListeners();
    }, fireImmediately: true);
  }
}

