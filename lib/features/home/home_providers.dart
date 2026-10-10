import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/protocol/recipient.dart';
import 'domain/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository?>((ref) => null);

final homeRecipientProvider = StreamProvider.autoDispose
    .family<Recipient?, String>((ref, recipientId) {
      final repository = ref.watch(homeRepositoryProvider);
      return repository?.watchRecipient(recipientId) ?? Stream.value(null);
    });

final recipientsStreamProvider =
    StreamProvider.autoDispose<List<Recipient>>((ref) {
      final repository = ref.watch(homeRepositoryProvider);
      if (repository == null) return Stream.value(const []);
      return repository.watchRecipients();
    });
