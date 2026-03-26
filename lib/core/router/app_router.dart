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

export 'app_route.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final routerProvider = Provider<GoRouter>((ref) {
  // authStateChangesProvider 및 userProvider를 리스닝하여 상태가 바뀔 때마다 라우터 새로고침 트리거
  final refreshNotifier = ValueNotifier<bool>(false);
  ref.listen(authStateChangesProvider, (previous, next) {
    if (previous?.value?.id != next.value?.id) {
      refreshNotifier.value = !refreshNotifier.value;
    }
  });
  ref.listen<AsyncValue<AppUser?>>(userProvider, (previous, next) {
    if (previous?.value?.id != next.value?.id) {
      refreshNotifier.value = !refreshNotifier.value;
    }
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
      final isCustomizing = state.matchedLocation == AppRoute.characterCustomize.path;

      // 1. Firebase Auth 수준에서 로그아웃임이 명확한 경우
      if (authState.hasValue && authState.value == null) {
        // 단, 온보딩을 안 봤다면 온보딩을 가장 먼저 띄움
        if (!hasSeenOnboarding) {
          return isOnboarding ? null : AppRoute.onboarding.path;
        }
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      // 2. 초기 로딩 중
      if (userAsync.isLoading && userAsync.value == null) {
        return null;
      }

      // 3. 앱 내부 상태 기반 검사 (최우선: 온보딩 시청 여부)
      if (!hasSeenOnboarding) {
        // 온보딩을 안 봤더라도 로그인 화면으로 직접 가려는 경우는 허용
        if (isLoggingIn) return null;
        return isOnboarding ? null : AppRoute.onboarding.path;
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

      // 6. 모든 절차를 완료했는데 해당 진입 화면들에 남아있는 경우 홈으로 이동
      if (isLoggingIn || isOnboarding || isCustomizing) {
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
