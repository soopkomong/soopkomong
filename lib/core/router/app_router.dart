import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/presentation/mypage/my_page.dart';
import 'package:soopkomong/presentation/mypage/profile_edit_page.dart';
import 'package:soopkomong/presentation/mypage/character_page/character_customize_page.dart';
import 'package:soopkomong/presentation/auth/sign_in_screen.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';
import 'package:soopkomong/core/router/app_route.dart';
import 'package:soopkomong/presentation/home/home_page.dart';
import 'package:soopkomong/presentation/collection/collection_page.dart';
import 'package:soopkomong/presentation/explore/explore_page.dart';
import 'package:soopkomong/presentation/friends/friends_page.dart';
import 'package:soopkomong/presentation/friends/widgets/friend_profile_page.dart';
import 'package:soopkomong/presentation/friends/widgets/friends_view_model.dart';
import 'package:soopkomong/presentation/layout/app_shell.dart';
import 'package:soopkomong/presentation/home/notifications_page.dart';
import 'package:soopkomong/domain/entities/app_user.dart';


export 'app_route.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final routerProvider = Provider<GoRouter>((ref) {
  // authStateChangesProvider 및 userProvider를 리스닝하여 상태가 바뀔 때마다 라우터 새로고침 트리거
  final refreshNotifier = ValueNotifier<bool>(false);
  ref.listen(authStateChangesProvider, (previous, next) {
    refreshNotifier.value = !refreshNotifier.value;
  });
  ref.listen(userProvider, (previous, next) {
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
      // 1. 현재 사용자 데이터를 비동기 데이터의 현재 값으로 가져옴
      final userAsync = ref.read(userProvider);
      
      // 초기 로딩 중이거나 새로고침 중이면서 데이터가 아직 없는 경우 리다이렉트 보류
      if (userAsync.isLoading && userAsync.value == null) {
        return null;
      }

      final user = userAsync.value;
      final isLoggingIn = state.matchedLocation == AppRoute.signIn.path;


      // 2. 사용자가 없고 로그인 중이 아니라면 로그인 페이지로
      if (user == null) {
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      // 3. 사용자가 있고 로그인 페이지에 있다면 홈으로
      if (isLoggingIn) {
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
                routes: [
                  GoRoute(
                    path: AppRoute.friendProfile.path,
                    name: AppRoute.friendProfile.name,
                    builder: (context, state) {
                      final friend = state.extra as FriendModel;
                      return FriendProfilePage(friend: friend);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
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
        path: AppRoute.signIn.path,
        name: AppRoute.signIn.name,
        builder: (context, state) => const SignInScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});
