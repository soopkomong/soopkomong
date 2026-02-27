import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/presentation/home/home_viewmodel.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index, WidgetRef ref) {
    if (index == 0) {
      ref.read(mapZoomResetProvider.notifier).triggerReset();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => _onTap(index, ref),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '홈',
        ),
        NavigationDestination(
          icon: Icon(Icons.collections_outlined),
          selectedIcon: Icon(Icons.collections),
          label: '도감',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: '정보',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: '친구',
        ),
      ],
    );
  }
}
