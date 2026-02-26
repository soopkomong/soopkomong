import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soopkomong/core/router/app_route.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('숲코몽'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.mypage.name),
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              '홈',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('지도'),
          ],
        ),
      ),
    );
  }
}
