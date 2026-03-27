import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/data/repositories/character_repository_impl.dart';
import 'package:soopkomong/domain/repositories/character_repository.dart';

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});
