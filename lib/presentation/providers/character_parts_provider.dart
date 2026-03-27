import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/providers/character_provider.dart';

/// 캐릭터 파츠 카테고리별 ID 목록을 Firestore에서 불러오는 Provider
final characterPartsProvider = FutureProvider<Map<String, List<String>>>((
  ref,
) async {
  final characterRepo = ref.read(characterRepositoryProvider);
  return characterRepo.getCharacterParts();
});
