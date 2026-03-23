import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 캐릭터 파츠 카테고리별 ID 목록을 Firestore에서 불러오는 Provider
final characterPartsProvider =
    FutureProvider<Map<String, List<String>>>((ref) async {
  final doc = await FirebaseFirestore.instance
      .collection('character_parts')
      .doc('metadata')
      .get();

  if (!doc.exists) {
    // 문서가 없는 경우 기본값 (준비된 기본 에셋들)
    return {
      'hairs': ['01', '02', '03'],
      'faces': ['smile', 'smile_girl', 'smile2', 'smile_girl2'],
      'clothes': ['01', '02', '03'],
      'shoes': ['01'],
    };
  }

  final data = doc.data() as Map<String, dynamic>;

  return {
    'hairs': List<String>.from(data['hairs'] ?? ['01', '02', '03']),
    'faces': List<String>.from(
      data['faces'] ?? ['smile', 'smile_girl', 'smile2', 'smile_girl2'],
    ),
    'clothes': List<String>.from(data['clothes'] ?? ['01', '02', '03']),
    'shoes': List<String>.from(data['shoes'] ?? ['01']),
  };
});
