import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:soopkomong/domain/entities/app_user.dart';
import 'package:soopkomong/domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CharacterRepositoryImpl(this._firestore, this._storage);

  @override
  Future<Map<String, List<String>>> getCharacterParts() async {
    final doc = await _firestore.collection('character_parts').doc('metadata').get();

    if (!doc.exists) {
      // 문서가 없는 경우 기본값
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
  }

  @override
  Future<void> saveCharacterSettings(
    AppUser user,
    Map<String, dynamic> characterSettings,
    Uint8List photoBytes,
  ) async {
    // 1. 기존 이미지 삭제 시도
    if (user.photoUrl != null &&
        user.photoUrl!.contains('firebasestorage.googleapis.com')) {
      try {
        await _storage.refFromURL(user.photoUrl!).delete();
      } catch (e) {
        // 무시 가능
      }
    }

    // 2. 새 이미지 업로드
    final fileName = 'profiles/${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
    final uploadTask = await _storage.ref(fileName).putData(photoBytes);
    final photoUrl = await uploadTask.ref.getDownloadURL();

    // 3. Firestore 업데이트
    await _firestore.collection('users').doc(user.id).set({
      'character_settings': characterSettings,
      'has_character': true,
      'photoUrl': photoUrl,
    }, SetOptions(merge: true));
  }
}
