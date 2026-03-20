import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/presentation/mypage/my_page.dart';
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
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/presentation/home/notifications_page.dart';

export 'app_route.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AppUser?>(ref.read(userProvider).value);
  ref.listen<AsyncValue<AppUser?>>(userProvider, (_, next) {
    notifier.value = next.value;
  });
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.home.path,
    redirect: (context, state) {
      final user = notifier.value;
      final isLoggingIn = state.matchedLocation == AppRoute.signIn.path;

      if (user == null) {
        return isLoggingIn ? null : AppRoute.signIn.path;
      }

      if (isLoggingIn) {
        return AppRoute.home.path;
      }

      return null;
    },
    refreshListenable: notifier,
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
