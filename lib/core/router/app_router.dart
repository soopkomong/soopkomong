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
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/presentation/auth/name_setting_page.dart';
import 'package:soopkomong/presentation/auth/tutorial_guide_page.dart';

export 'app_route.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final routerProvider = Provider<GoRouter>((ref) {
  // authStateChangesProvider 및 userProvider를 리스닝하여 상태가 바뀔 때마다 라우터 새로고침 트리거
  final refreshNotifier = ValueNotifier<bool>(false);
  // authStateChangesProvider 및 userProvider의 상태가 변할 때마다 라우터 새로고침 트리거
  ref.listen(authStateChangesProvider, (_, _) {
    refreshNotifier.value = !refreshNotifier.value;
  });
  ref.listen(userProvider, (_, _) {
    refreshNotifier.value = !refreshNotifier.value;
  });
  // 온보딩 완료 시 라우터 새로고침 트리거
  ref.listen<bool>(onboardingProvider, (_, _) {
    refreshNotifier.value = !refreshNotifier.value;
  });
  final notifier = ValueNotifier<AppUser?>(ref.read(userProvider).value);
  ref.listen<AsyncValue<AppUser?>>(userProvider, (_, next) {
    notifier.value = next.value;
  });
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final userAsync = ref.read(userProvider);

      final hasSeenOnboarding = ref.read(onboardingProvider);
      final isLoggingIn = state.matchedLocation == AppRoute.signIn.path;
      final isOnboarding = state.matchedLocation == AppRoute.onboarding.path;
      final isCustomizing =
          state.matchedLocation == AppRoute.characterCustomize.path;
      final isNameSetting = state.matchedLocation == AppRoute.nameSetting.path;

      // 0. 최우선: 온보딩 시청 여부 (로그인 여부와 상관없이 가장 먼저 보여줌)
      if (!hasSeenOnboarding) {
        if (isLoggingIn) return null; // 로그인 화면으로 가려 할 때만 허용
        return isOnboarding ? null : AppRoute.onboarding.path;
      }

      // 1. Firebase Auth 수준에서 로그아웃임이 명확한 경우
      if (authState.hasValue && authState.value == null) {
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      // 2. Firebase Auth와 Firestore 데이터 간의 사용자가 일치하는지 확인 (계정 전환 대비)
      // authState에는 새 유저가 찍혔는데 userAsync에는 아직 옛날 유저 데이터가 남아있는 경우를 방지
      if (authState.hasValue &&
          userAsync.hasValue &&
          authState.value != null &&
          userAsync.value != null &&
          authState.value!.id != userAsync.value!.id) {
        return null; // 데이터 로딩을 기다림
      }

      // 3. 초기 로딩 중
      if (userAsync.isLoading && userAsync.value == null) {
        return null;
      }

      final user = userAsync.value;

      // 4. 온보딩 완료 후, 사용자 데이터가 없는 경우 (로그아웃 상태)
      if (user == null) {
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      // 5. 로그인 성공 후, 캐릭터가 없는 경우
      if (!user.hasCharacter) {
        return isCustomizing ? null : AppRoute.characterCustomize.path;
      }

      // 6. 이름 설정 여부 확인
      if (!user.hasName) {
        return isNameSetting ? null : AppRoute.nameSetting.path;
      }

      // 7. 튜토리얼 확인 여부
      final isTutorial = state.matchedLocation == AppRoute.tutorialGuide.path;
      if (!user.hasSeenTutorial) {
        return isTutorial ? null : AppRoute.tutorialGuide.path;
      }

      // 8. 로그인 화면이나 설정 화면에 있는데 데이터가 다 있다면 홈으로 리다이렉트
      if (isLoggingIn || isCustomizing || isNameSetting || isTutorial) {
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
