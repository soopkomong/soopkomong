import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/domain/repositories/step_repository.dart';
import 'package:soopkomong/data/repositories/step_repository_impl.dart';

import 'package:soopkomong/presentation/providers/common_providers.dart';

final stepRepositoryProvider = Provider<StepRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StepRepositoryImpl(prefs);
});
