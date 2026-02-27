import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_initializer.dart';
import 'core/router/app_router.dart';

void main() async {
  // 앱 관련 모든 비동기 설정 초기화
  await AppInitializer.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}
