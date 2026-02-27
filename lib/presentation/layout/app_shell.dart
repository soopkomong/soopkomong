import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/presentation/widgets/bottom_nav_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigationBar(
        navigationShell: navigationShell,
      ),
    );
  }
}
