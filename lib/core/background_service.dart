import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/firebase_options.dart';
import 'package:soopkomong/data/repositories/step_repository_impl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("[Workmanager] Background task started: $task");

    try {
      // Firebase 초기화 (백그라운드 프로세스이므로 별도 초기화 필요)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final prefs = await SharedPreferences.getInstance();
      final stepRepo = StepRepositoryImpl(prefs);

      // 1. 걸음수 동기화 (건강 앱 등)
      final stepData = await stepRepo.syncWithHealthApp();
      debugPrint(
        "[Workmanager] Synced Today Steps: ${stepData.todaySteps}, Total: ${stepData.totalSteps}",
      );

      // 2. 부화 조건 체크 및 Firestore 업데이트
      // 주의: 백그라운드에서는 Riverpod을 사용할 수 없으므로 직접 Repository/Firestore 접근
      final userId = prefs.getString('user_id'); // 로그인 시 저장해둬야 함
      if (userId != null) {
        await _checkBackgroundHatching(userId, stepData.totalSteps);
      }

      return Future.value(true);
    } catch (e) {
      debugPrint("[Workmanager] Error: $e");
      return Future.value(false);
    }
  });
}

Future<void> _checkBackgroundHatching(String userId, int currentSteps) async {
  final firestore = FirebaseFirestore.instance;

  // 부화하지 않은 펫들 가져오기
  final snapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('acquired_soopkomons')
      .where('isHatched', isEqualTo: false)
      .get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final stepsAtDiscovery = data['stepsAtDiscovery'] as int;

    if ((currentSteps - stepsAtDiscovery) >= 1000) {
      // 부화 처리
      await doc.reference.update({
        'isHatched': true,
        'currentTotalSteps': currentSteps,
      });

      // 데이터에서 공원 이름과 숲코몽 이름 추출 (기본값 설정)
      final parkName = data['discoveredSpotName'] ?? '생태공원';
      final petName = data['name'] ?? '숲코몽';

      // 알림 발송 - 사용자의 요청에 따른 형식 ("00동 공원 숲코몽 부화")
      await _showNotification(
        '$parkName 숲코몽 부화',
        '$parkName에 $petName 숲코몽이 태어났어요! 도감에서 자세한 정보를 확인하세요!',
      );
    }
  }
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'hatching_channel',
        'Hatching Notifications',
        channelDescription: 'Notifications for pet hatching',
        importance: Importance.max,
        priority: Priority.high,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: platformChannelSpecifics,
    payload: 'item x',
  );
}
