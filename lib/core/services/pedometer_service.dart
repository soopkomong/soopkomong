import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// 만보기 데이터와 권한 상태를 관리하는 Provider입니다.
final pedometerProvider = AsyncNotifierProvider<PedometerService, int>(() {
  return PedometerService();
});

class PedometerService extends AsyncNotifier<int> {
  StreamSubscription<StepCount>? _subscription;

  @override
  FutureOr<int> build() {
    // 앱이 꺼질 때 스트림 구독 해제
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return 0; // 초기 걸음 수
  }

  /// 사용자가 명시적으로 권한 승인 및 측정을 시작할 때 호출합니다.
  /// 예: 홈 화면의 '만보기 시작' 버튼 또는 화면 진입 시 useEffect 등에서 호출
  Future<void> requestPermissionAndStart() async {
    state = const AsyncLoading();

    try {
      // 1. 신체 활동 권한 요청
      final status = Platform.isIOS
          ? await Permission.sensors.request()
          : await Permission.activityRecognition.request();

      if (status.isGranted) {
        // 2. 권한 승인 시 스트림 구독 시작
        _startListening();
      } else if (status.isPermanentlyDenied) {
        // 사용자가 영구적으로 거부한 경우 설정창으로 유도하거나 에러 상태 전달
        state = AsyncError(
          '권한이 영구적으로 거부되었습니다. 설정에서 허용해주세요.',
          StackTrace.current,
        );
      } else {
        // iOS 시뮬레이터 등에서 센서가 없어 거부되는 경우 에러를 띄우지 않고 0으로 유지
        if (Platform.isIOS) {
          debugPrint('신체 활동 권한 거부됨 (iOS 시뮬레이터 가능성)');
          state = const AsyncData(0);
        } else {
          state = AsyncError('신체 활동 권한이 필요합니다.', StackTrace.current);
        }
      }
    } catch (e, stack) {
      state = AsyncError('권한 요청 중 오류 발생: $e', stack);
    }
  }

  void _startListening() {
    _subscription?.cancel();

    // Pedometer 패키지의 스트림 구독
    _subscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        // 센서로부터 새로운 걸음 수가 들어오면 상태 업데이트
        state = AsyncData(event.steps);
      },
      onError: (error) {
        // 하드웨어 센서 문제 시 iOS에서는 무시(0으로 유지), 그 외 플랫폼은 에러 처리
        if (Platform.isIOS) {
          debugPrint('만보기 센서 에러(iOS 무시): $error');
          state = const AsyncData(0);
        } else {
          state = AsyncError(
            '만보기 센서를 찾을 수 없거나 오류가 발생했습니다: $error',
            StackTrace.current,
          );
        }
      },
      cancelOnError: false,
    );
  }
}
