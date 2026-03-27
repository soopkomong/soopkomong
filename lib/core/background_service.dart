import 'package:workmanager/workmanager.dart';
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
      // 주의: 백그라운드에서는 Riverpod을 사용할 수 없으므로 직접 의존성을 주입하여 UseCase 실행
      final userId = prefs.getString('user_id'); // 로그인 시 저장해둬야 함
      if (userId != null) {
        final remoteDataSource = RemoteLocationDataSourceImpl(firestore: FirebaseFirestore.instance);
        final soopkomonRepo = SoopkomonRepositoryImpl(remoteDataSource: remoteDataSource);
        final checkHatchingUseCase = CheckHatchingUseCase(soopkomonRepo);
        
        final notifications = await checkHatchingUseCase.execute(userId, stepData.totalSteps);
        
        for (var msg in notifications) {
          await _showNotification('숲코몽 부화', msg);
        }

        // 3. 생태 공원 진입 감지 및 100걸음 걷기 체크 (백그라운드 "최선 노력" 보장 방식)
        bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await geo.Geolocator.checkPermission();
          if (permission == geo.LocationPermission.always || permission == geo.LocationPermission.whileInUse) {
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
                  position.latitude, position.longitude, loc.lat, loc.lng
                );
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
                  final stepsInPark = stepData.todaySteps - savedEntrySteps;
                  if (stepsInPark >= 100 && parkPetIds.isNotEmpty) {
                    final targetTemplateId = parkPetIds.first;
                    final userPets = await soopkomonRepo.getUserSoopkomons(userId).first;
                    final alreadyHas = userPets.any((p) => p.templateId == targetTemplateId);

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
                          stepsAtDiscovery: stepData.totalSteps,
                          currentTotalSteps: stepData.totalSteps,
                          grade: templateData['grade'] ?? 'C',
                        );

                        await soopkomonRepo.addSoopkomon(userId, newPet);
                        await _showNotification(
                          '숲코몽 획득!',
                          '$detectedParkName에서 100보를 걷고 ${newPet.name} 숲코몽을 발견했어요!'
                        );

                        prefs.remove('bg_park_id');
                        prefs.remove('bg_park_entry_steps');
                      }
                    }
                  }
                } else {
                  // 새로 진입한 경우
                  prefs.setInt('bg_park_id', detectedParkId);
                  prefs.setInt('bg_park_entry_steps', stepData.todaySteps);
                }
              } else {
                // 공원을 벗어난 경우 삭제
                prefs.remove('bg_park_id');
                prefs.remove('bg_park_entry_steps');
              }
            } catch (locError) {
              debugPrint("[Workmanager] Location fetch error: $locError");
            }
          }
        }
      }

      return Future.value(true);
    } catch (e) {
      debugPrint("[Workmanager] Error: $e");
      return Future.value(false);
    }
  });
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
