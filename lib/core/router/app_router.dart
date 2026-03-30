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
  final refreshNotifier = RouterRefreshNotifier();
  
  // 인증 상태, 사용자 데이터, 온보딩 상태 변경 시 라우터 새로고침
  ref.listen(authStateChangesProvider, (_, _) => refreshNotifier.notify());
  ref.listen(userProvider, (_, _) => refreshNotifier.notify());
  ref.listen(onboardingProvider, (_, _) => refreshNotifier.notify());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userAsync = ref.read(userProvider);
      final hasSeenOnboarding = ref.read(onboardingProvider);

      final isLoggingIn = state.matchedLocation == AppRoute.signIn.path;
      final isOnboarding = state.matchedLocation == AppRoute.onboarding.path;
      final isCustomizing = state.matchedLocation == AppRoute.characterCustomize.path;
      final isNameSetting = state.matchedLocation == AppRoute.nameSetting.path;
      final isTutorial = state.matchedLocation == AppRoute.tutorialGuide.path;

      debugPrint('DEBUG: [Router] 목적지: ${state.matchedLocation}, 온보딩 완료여부: $hasSeenOnboarding, 인증상태: ${authState.value != null}');

      // 0. 최우선: 온보딩 시청 여부
      if (!hasSeenOnboarding) {
        if (isOnboarding) {
          debugPrint('DEBUG: [Router] 온보딩이 필요하며, 이미 온보딩 페이지입니다. 이동 중단(null).');
          return null;
        }
        debugPrint('DEBUG: [Router] 온보딩이 필요합니다. /onboarding으로 리다이렉트합니다.');
        return AppRoute.onboarding.path;
      }

      // 1. Firebase Auth 수준에서 로그아웃임이 명확한 경우
      if (authState.hasValue && authState.value == null) {
        if (isLoggingIn || isOnboarding) return null;
        return AppRoute.signIn.path;
      }

      // 2. 초기 로딩 중 (사용자 데이터가 아직 없는 경우)
      if (userAsync.isLoading && userAsync.value == null) {
        return null; // 로딩 완료 후 refreshNotifier에 의해 다시 리다이렉트됨
      }

      final user = userAsync.value;

      // 3. 사용자 데이터가 없는 경우 (로그아웃 상태로 간주)
      if (user == null) {
        if (isLoggingIn || isOnboarding) return null;
        return AppRoute.signIn.path;
      }

      // 4. 로그인 성공 후, 단계별 설정 확인
      
      // 캐릭터 설정 여부
      if (!user.hasCharacter) {
        if (isCustomizing) return null;
        return AppRoute.characterCustomize.path;
      }

      // 이름 설정 여부
      if (!user.hasName) {
        if (isNameSetting) return null;
        return AppRoute.nameSetting.path;
      }

      // 튜토리얼 확인 여부
      if (!user.hasSeenTutorial) {
        if (isTutorial) return null;
        return AppRoute.tutorialGuide.path;
      }

      // 5. 모든 설정이 완료된 상태에서 인증 관련 페이지 방지
      if (isLoggingIn || isOnboarding || isCustomizing || isNameSetting || isTutorial) {
        return AppRoute.home.path;
      }

      return null;
    },
    refreshListenable: refreshNotifier,
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

/// 라우터 리프레시를 관리하는 ChangeNotifier
class RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

