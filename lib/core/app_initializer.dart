import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soopkomong/firebase_options.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱 구동에 필요한 비동기 초기화 작업들을 처리하는 클래스입니다.
/// main.dart를 깔끔하게 유지하기 위해 초기화 로직을 분리했습니다.
class AppInitializer {
  /// Firebase, dotenv, Mapbox 등 모든 필수 서비스 초기화
  static Future<void> init() async {
    // Flutter 엔진 바인딩 초기화
    WidgetsFlutterBinding.ensureInitialized();

    // 환경 변수 셋업 (.env)
    await dotenv.load(fileName: ".env");

    // Mapbox 퍼블릭 액세스 토큰 설정
    MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);

    // Firebase 연동 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
