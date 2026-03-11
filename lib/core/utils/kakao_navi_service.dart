import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoNaviService {
  static Future<void> startNavi({
    required String naviLoc,
    required double naviLat,
    required double naviLng,
  }) async {
    bool isNaviInstalled = await NaviApi.instance.isKakaoNaviInstalled();

    if (isNaviInstalled) {
      await NaviApi.instance.navigate(
        destination: Location(
          name: naviLoc,
          x: naviLng.toString(),
          y: naviLat.toString(),
        ),
        option: NaviOption(coordType: CoordType.wgs84),
      );
    } else {
      // 카카오내비 앱 설치 페이지로 이동
      await NaviApi.instance.navigate(
        destination: Location(
          name: naviLoc,
          x: naviLng.toString(),
          y: naviLat.toString(),
        ),
        option: NaviOption(
          coordType: CoordType.wgs84,
        ), // web navigation fallback
      );
    }
  }
}
