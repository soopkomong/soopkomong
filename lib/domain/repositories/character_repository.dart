import 'dart:typed_data';
import 'package:soopkomong/domain/entities/app_user.dart';

abstract class CharacterRepository {
  Future<Map<String, List<String>>> getCharacterParts();
  Future<void> saveCharacterSettings(
    AppUser user,
    Map<String, dynamic> characterSettings,
    Uint8List photoBytes,
  );
}
