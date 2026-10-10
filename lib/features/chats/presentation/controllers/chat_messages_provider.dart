import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/settings_providers.dart';
import '../../domain/chat_repository.dart';
import '../../domain/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository?>((ref) {
  return ref.watch(appRuntimeProvider)?.chatRepository;
});

typedef ChatMessagesRequest = ({String chatId, int limit});

final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, ChatMessagesRequest>((ref, request) {
      final repository = ref.watch(chatRepositoryProvider);
      if (repository == null) return Stream.value(const []);
      return repository.watchMessages(
        chatId: request.chatId,
        limit: request.limit,
      );
    });
