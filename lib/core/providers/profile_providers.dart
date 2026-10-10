import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/message_records.dart';
import '../../features/profile/domain/profile_repository.dart';
import 'settings_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepositoryPort?>(
  (ref) => ref.watch(appRuntimeProvider)?.profileRepository,
);

final currentUserProfileProvider =
    StreamProvider.autoDispose<UserProfile?>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      if (repository == null) return Stream.value(null);
      return repository.watchCurrentUser();
    });
