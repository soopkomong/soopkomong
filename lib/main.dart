import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:soopkomong/core/app_initializer.dart';
import 'package:soopkomong/core/theme/app_colors.dart';
import 'core/router/app_router.dart';

void main() async {
  await AppInitializer.init();
  await GoogleSignIn.instance.initialize();

  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: 'cc5aad14a59b4d716bd3ea7ba3b7fb06');

  runApp(const ProviderScope(child: MyApp()));

  // 키 해시 출력 (디버그 콘솔에서 확인)
  print("현재 앱의 키 해시: ${await KakaoSdk.origin}");
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary500,
          primary: AppColors.primary500,
          surface: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}
