import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/core/app_initializer.dart';
import 'package:soopkomong/core/theme/app_theme.dart';
import 'package:workmanager/workmanager.dart';
import 'package:soopkomong/core/background_service.dart';
import 'package:soopkomong/presentation/providers/common_providers.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("DEBUG: Application main() started.");

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();

  debugPrint("DEBUG: [main] Workmanager initialization starting...");
  // Workmanager 초기화
  try {
    await Workmanager().initialize(
      callbackDispatcher,
    );
    debugPrint("DEBUG: [main] Workmanager initialization finished.");
  } catch (e) {
    debugPrint("DEBUG: [main] Workmanager initialization failed: $e");
  }

  // 주기적인 백그라운드 작업 등록 (Android 전용, 15분 간격)
  if (Platform.isAndroid) {
    debugPrint(
      "DEBUG: [main] Android platform detected, registering periodic task...",
    );
    try {
      await Workmanager().registerPeriodicTask(
        "hatchingTask",
        "checkHatching",
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
      );
      debugPrint("DEBUG: [main] Periodic task registered successfully.");
    } catch (e) {
      debugPrint("DEBUG: [main] Failed to register periodic task: $e");
    }
  }

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // AppInitializer 초기화 (Firebase, Dotenv 등)
  await AppInitializer.init();

  // Google Sign In 초기화
  await GoogleSignIn.instance.initialize();

  // 언어 설정 초기화
  await container.read(localeProvider.notifier).init();

  // 카카오 SDK 초기화 (.env에서 키 로드)
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => child!,
    );
  }
}
