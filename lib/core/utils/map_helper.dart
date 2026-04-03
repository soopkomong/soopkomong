import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// [Core Layer] - Utility
/// Mapbox 지도에서 사용되는 커스텀 마커(비트맵) 생성과 관련된 공통 유틸리티 함수 모음입니다.
/// 비즈니스 로직을 포함하지 않고 오로지 그래픽 처리만을 담당하는 외부 독립적 도구입니다.
Future<Uint8List> createCustomMarkerBitmap(String title, Color color) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  const double size = 100.0;

  final Paint paint = Paint()..color = color;
  final Paint borderPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6.0;

  // Draw circle
  canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 10, paint);
  canvas.drawCircle(
    const Offset(size / 2, size / 2),
    size / 2 - 10,
    borderPaint,
  );

  // Draw text
  if (title.isNotEmpty) {
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: title[0], // Show first letter
      style: const TextStyle(
        fontSize: 40.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );
  }

  final ui.Image image = await pictureRecorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return byteData!.buffer.asUint8List();
}

Future<Uint8List> createIconMarkerBitmap(
  IconData iconData,
  Color color, {
  double size = 150.0,
}) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

  textPainter.text = TextSpan(
    text: String.fromCharCode(iconData.codePoint),
    style: TextStyle(
      fontSize: size,
      color: color,
      fontFamily: iconData.fontFamily,
      package: iconData.fontPackage,
    ),
  );

  textPainter.layout();

  textPainter.paint(
    canvas,
    Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
  );

  final ui.Image image = await pictureRecorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );

  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return byteData!.buffer.asUint8List();
}

/// SVG 파일을 읽어 지정된 색상을 적용한 후 Mapbox 마커용 비트맵(Uint8List)으로 변환합니다.
Future<Uint8List> createSvgMarkerBitmap(
  String assetPath,
  Color color, {
  double size = 150.0,
}) async {
  // SVG 내용을 문자열로 로드하여 특정 색상만 치환합니다.
  String svgString = await rootBundle.loadString(assetPath);

  // 입력받은 Color에서 투명도를 제외한 RGB 헥사 코드를 생성합니다.
  final String hexColor =
      '#${color.value.toRadixString(16).substring(2).padLeft(6, '0').toUpperCase()}';

  // Pin.svg의 본체 색상(#FD8224)만 테마 색상으로 변경합니다.
  // 나뭇잎인 'white' 부분은 치환되지 않고 그대로 유지됩니다.
  svgString = svgString.replaceAll('#FD8224', hexColor);

  // 치환된 SVG 문자열을 로딩합니다.
  final PictureInfo pictureInfo = await vg.loadPicture(
    SvgStringLoader(svgString),
    null,
  );

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final double width = size;
  final double height = size;

  // SVG 크기에 맞춰 스케일 계산
  final double scaleX = width / pictureInfo.size.width;
  final double scaleY = height / pictureInfo.size.height;
  final double scale = scaleX < scaleY ? scaleX : scaleY;

  // 전체 색상을 덮어쓰는 ColorFilter를 제거하여 나뭇잎의 흰색이 유지되도록 합니다.
  canvas.save();
  canvas.scale(scale);
  canvas.drawPicture(pictureInfo.picture);
  canvas.restore();

  final ui.Image image = await recorder.endRecording().toImage(
    width.toInt(),
    height.toInt(),
  );

  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  return byteData!.buffer.asUint8List();
}
