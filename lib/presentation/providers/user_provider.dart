import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/presentation/providers/auth_provider.dart';

/// 현재 로그인한 사용자의 Firestore 문서를 실시간으로 감시하는 Provider
final userDocumentProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null || user.id.trim().isEmpty) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .snapshots();
});
