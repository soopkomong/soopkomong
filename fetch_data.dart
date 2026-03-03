import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

void main() async {
  // 1. .env 파일 로드
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // 2. 환경 변수에서 값 가져오기 (null 처리 포함)
  final String? serviceKey = env['ECOLOGY_SERVICE_KEY'];
  final String? baseUrl = env['ECOLOGY_BASE_URL'];

  if (serviceKey == null || baseUrl == null) {
    print('오류: .env 파일에서 ECOLOGY_SERVICE_KEY 또는 ECOLOGY_BASE_URL을 찾을 수 없습니다.');
    return;
  }

  const String mobileApp = 'soopkomong';
  const String mobileOS = 'ETC';
  const int numOfRows = 100;

  int pageNo = 1;
  int totalCount = 0;
  List<dynamic> allData = [];
  bool hasMoreData = true;

  print('생태 관광 데이터 수집을 시작합니다...');

  while (hasMoreData) {
    // 3. 환경 변수가 적용된 API 요청 URL 구성
    final Uri url = Uri.parse(
      '$baseUrl?serviceKey=$serviceKey'
      '&numOfRows=$numOfRows'
      '&pageNo=$pageNo'
      '&MobileOS=$mobileOS'
      '&MobileApp=$mobileApp'
      '&_type=json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = jsonDecode(decodedBody);

        final Map<String, dynamic>? responseBody =
            jsonResponse['response']['body'];

        if (responseBody == null) {
          print('데이터 형식이 올바르지 않습니다. API 키 오류 또는 서버 문제일 수 있습니다.');
          break;
        }

        totalCount = responseBody['totalCount'] ?? 0;
        final items = responseBody['items'];

        if (items != null && items != '') {
          final rawItem = items['item'];
          final List<dynamic> itemList = rawItem is List ? rawItem : [rawItem];
          allData.addAll(itemList);
        }

        print('진행 상황: ${allData.length} / $totalCount 건 수집 완료 (페이지 $pageNo)');

        if (allData.length >= totalCount || (items == null || items == '')) {
          hasMoreData = false;
        } else {
          pageNo++;
        }
      } else {
        print('API 호출 실패: 상태 코드 ${response.statusCode}');
        hasMoreData = false;
      }
    } catch (e) {
      print('오류 발생: $e');
      hasMoreData = false;
    }
  }

  // 4. 추출된 데이터를 assets 폴더 하위 JSON 파일로 저장
  if (allData.isNotEmpty) {
    final Directory assetsDir = Directory('assets');
    if (!await assetsDir.exists()) {
      await assetsDir.create();
    }

    final File file = File('assets/green_tour_data.json');
    final String jsonString = JsonEncoder.withIndent('  ').convert(allData);
    await file.writeAsString(jsonString);

    print('저장 완료: ${file.path} 파일에 총 ${allData.length}건의 데이터가 저장되었습니다.');
  } else {
    print('수집된 데이터가 없어 파일을 생성하지 않았습니다.');
  }
}
