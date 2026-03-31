import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soopkomong/firebase_options.dart';
import 'package:soopkomong/data/repositories/step_repository_impl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:soopkomong/data/datasources/remote_location_datasource.dart';
import 'package:soopkomong/data/repositories/soopkomon_repository_impl.dart';
import 'package:soopkomong/domain/usecases/check_hatching_usecase.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:uuid/uuid.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:pedometer/pedometer.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'soopkomong_bg_service',
    'Soopkomong Background Service',
    description: '숲코몽 걸음 측정 및 부화 처리 동작',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'soopkomong_bg_service',
      initialNotificationTitle: '숲코몽',
      initialNotificationContent: '숲코몽 걸음 측정 중...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

Future<void> startBackgroundServiceSafe() async {
  final service = FlutterBackgroundService();
  if (await service.isRunning()) return;

  if (Platform.isAndroid) {
    // 안드로이드 14 이상에서는 포어그라운드 서비스 시작 시 권한이 없으면 SecurityException 발생
    final locationGranted = await Permission.locationAlways.isGranted || await Permission.locationWhenInUse.isGranted;
    final activityGranted = await Permission.activityRecognition.isGranted;
    final notificationGranted = await Permission.notification.isGranted;

    if (locationGranted && activityGranted && notificationGranted) {
      debugPrint("[BackgroundService] Permissions verified, starting service.");
      await service.startService();
    } else {
      debugPrint("[BackgroundService] Required permissions not fully granted. Skipping service start.");
    }
  } else {
    await service.startService();
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _executeBackgroundLogic();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 서비스 시작 시 즉시 1회 실행
  await _executeBackgroundLogic();

  // 강제 15분 주기 타이머 시작
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    debugPrint("[BackgroundService] 15분 주기 타이머 동작...");
    await _executeBackgroundLogic();
  });
}

Future<void> _executeBackgroundLogic() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final prefs = await SharedPreferences.getInstance();
    final stepRepo = StepRepositoryImpl(prefs);

    // 1. Pedometer 값을 1회 가져와서 처리
    StepCount? stepCount;
    try {
      stepCount = await Pedometer.stepCountStream.first;
    } catch (e) {
      debugPrint("[BackgroundService] Pedometer fetch error: $e");
    }

    int currentTotalSteps = await stepRepo.getTotalSteps();
    int currentTodaySteps = await stepRepo.getTodaySteps();

    if (stepCount != null) {
      final stepData = await stepRepo.updateFromPedometer(stepCount.steps);
      currentTotalSteps = stepData.totalSteps;
      currentTodaySteps = stepData.todaySteps;
      debugPrint(
        "[BackgroundService] Pedometer updated. Today Steps: $currentTodaySteps, Total: $currentTotalSteps",
      );
    } else {
      // 센서 실패 시 단지 날짜 바뀌었는지 확인 위해 함수 호출
      currentTodaySteps = await stepRepo.getTodaySteps();
    }

    // 2. 부화 조건 체크 및 Firestore 업데이트
    final userId = prefs.getString('user_id');
    if (userId != null) {
      if (currentTotalSteps == 0) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final int remoteTotalSteps = userDoc.data()?['totalSteps'] ?? 0;
          if (remoteTotalSteps > 0) {
            await stepRepo.setTotalSteps(remoteTotalSteps);
            currentTotalSteps = remoteTotalSteps;
            debugPrint("[BackgroundService] Restored totalSteps from Firestore: $remoteTotalSteps");
          }
        }
      } else {
        try {
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'totalSteps': currentTotalSteps,
            'lastStepUpdateAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint("[BackgroundService] Firestore totalSteps update failed: $e");
        }
      }

      final remoteDataSource = RemoteLocationDataSourceImpl(
          firestore: FirebaseFirestore.instance);
      final soopkomonRepo = SoopkomonRepositoryImpl(
          remoteDataSource: remoteDataSource);
      final checkHatchingUseCase = CheckHatchingUseCase(soopkomonRepo);

      final notifications =
          await checkHatchingUseCase.execute(userId, currentTotalSteps);

      for (var msg in notifications) {
        await _showNotification('숲코몽 부화', msg);
      }

      // 3. 생태 공원 진입 감지 및 100걸음 걷기 체크
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await geo.Geolocator.checkPermission();
        if (permission == geo.LocationPermission.always ||
            permission == geo.LocationPermission.whileInUse) {
          try {
            final position = await geo.Geolocator.getCurrentPosition(
              locationSettings: const geo.LocationSettings(
                accuracy: geo.LocationAccuracy.medium,
                timeLimit: Duration(seconds: 15),
              ),
            );

            final locations = await remoteDataSource.getRemoteLocations();

            int? detectedParkId;
            String? detectedParkName;
            List<String> parkPetIds = [];

            for (final loc in locations) {
              final distance = geo.Geolocator.distanceBetween(
                  position.latitude, position.longitude, loc.lat, loc.lng);
              if (distance <= loc.radius) {
                detectedParkId = loc.id;
                detectedParkName = loc.name;
                parkPetIds = loc.petIds;
                break;
              }
            }

            if (detectedParkId != null) {
              final savedParkId = prefs.getInt('bg_park_id');
              final savedEntrySteps = prefs.getInt('bg_park_entry_steps');

              if (savedParkId == detectedParkId && savedEntrySteps != null) {
                final stepsInPark = currentTodaySteps - savedEntrySteps;
                if (stepsInPark >= 100 && parkPetIds.isNotEmpty) {
                  final targetTemplateId = parkPetIds.first;
                  final userPets =
                      await soopkomonRepo.getUserSoopkomons(userId).first;
                  final alreadyHas = userPets
                      .any((p) => p.templateId == targetTemplateId);

                  if (!alreadyHas) {
                    final templateQuery = await FirebaseFirestore.instance
                        .collection('soopkomon_templates')
                        .where('templateId', isEqualTo: targetTemplateId)
                        .limit(1)
                        .get();

                    if (templateQuery.docs.isNotEmpty) {
                      final templateData = templateQuery.docs.first.data();
                      final newPet = Soopkomon(
                        instanceId: const Uuid().v4(),
                        templateId: targetTemplateId,
                        name: templateData['name'] ?? '숲코몽',
                        discoveredSpotId: detectedParkId.toString(),
                        discoveredSpotName: detectedParkName ?? '생태공원',
                        discoveredAddr: templateData['eggImagePath'] ?? '',
                        discoveredAt: DateTime.now(),
                        stepsAtDiscovery: currentTotalSteps,
                        currentTotalSteps: currentTotalSteps,
                        grade: templateData['grade'] ?? 'C',
                      );

                      await soopkomonRepo.addSoopkomon(userId, newPet);
                      await _showNotification(
                          '숲코몽 획득!',
                          '$detectedParkName에서 100보를 걷고 ${newPet.name} 숲코몽을 발견했어요!');

                      prefs.remove('bg_park_id');
                      prefs.remove('bg_park_entry_steps');
                    }
                  }
                }
              } else {
                prefs.setInt('bg_park_id', detectedParkId);
                prefs.setInt('bg_park_entry_steps', currentTodaySteps);
              }
            } else {
              prefs.remove('bg_park_id');
              prefs.remove('bg_park_entry_steps');
            }
          } catch (locError) {
            debugPrint("[BackgroundService] Location fetch error: $locError");
          }
        }
      }
    }
  } catch (e) {
    debugPrint("[BackgroundService] Error: $e");
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

