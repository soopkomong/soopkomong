import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

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
