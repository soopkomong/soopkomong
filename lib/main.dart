import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soopkomong/core/router/app_router.dart';
import 'package:soopkomong/core/app_initializer.dart';

void main() async {
  await AppInitializer.init();
  await GoogleSignIn.instance.initialize();
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
