import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/presentation/widgets/app_bottom_nav_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            navigationShell,
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AppBottomNavigationBar(navigationShell: navigationShell),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
