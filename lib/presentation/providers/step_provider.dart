import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soopkomong/domain/repositories/step_repository.dart';
import 'package:soopkomong/data/repositories/step_repository_impl.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // main에서 override 필요
});

final stepRepositoryProvider = Provider<StepRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StepRepositoryImpl(prefs);
});
