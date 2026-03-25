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
      // 1. Firebase Auth 상태 및 사용자 데이터 가져오기
      final authState = ref.read(authStateChangesProvider);
      final userAsync = ref.read(userProvider);

      final isLoggingIn = state.matchedLocation == AppRoute.signIn.path;

      // 2. Firebase Auth 수준에서 로그아웃임이 명확한 경우
      // (지연 없이 즉시 로그인 화면으로 보내기 위해 최우선 확인)
      if (authState.hasValue && authState.value == null) {
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      // 3. 초기 로딩 중이면서 데이터가 아직 없는 경우 (로그인 프로세스 중 등)
      if (userAsync.isLoading && userAsync.value == null) {
        return null; // 현재 위치 유지 (로딩 인디케이터 등 노출을 위해)
      }

      final user = userAsync.value;
      final hasSeenOnboarding = ref.read(onboardingProvider);

      // 4. 사용자 데이터가 없는 경우 (로그아웃 상태)
      if (user == null) {
        // 로그아웃 상태에서는 항상 로그인 화면으로 이동
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      // 5. 로그인 상태인 경우, 온보딩을 보지 않았다면 온보딩 화면으로 이동
      if (!hasSeenOnboarding) {
        return state.matchedLocation == AppRoute.onboarding.path
            ? null
            : AppRoute.onboarding.path;
      }

      // 6. 로그인 성공 및 온보딩 완료 후 로그인 화면이나 온보딩 화면에 머물러 있는 경우 홈으로
      if (isLoggingIn || state.matchedLocation == AppRoute.onboarding.path) {
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
