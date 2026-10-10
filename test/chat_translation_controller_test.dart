import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tureon/core/protocol/message_item.dart';
import 'package:tureon/core/providers/settings_providers.dart';
import 'package:tureon/features/chats/domain/chat_repository.dart';
import 'package:tureon/features/chats/domain/chat_message.dart';
import 'package:tureon/features/chats/domain/message_translation.dart';
import 'package:tureon/features/chats/domain/translation_repository.dart';
import 'package:tureon/features/chats/domain/language_detection_repository.dart';
import 'package:tureon/features/chats/presentation/controllers/chat_translation_controller.dart';

class _Repository implements ChatRepository {
  final saved = <MessageTranslation>[];
  @override
  Map<String, MessageTranslation> loadMessageTranslations(
    List<String> ids, {
    required String targetLanguage,
  }) => {};
  @override
  Future<bool> saveMessageTranslation(MessageTranslation value) async {
    saved.add(value);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Detector implements MessageLanguageDetector {
  @override
  Future<String> identifyLanguage(String text) async => 'en';
}

class _Translator implements TranslationRepository {
  final pending = <Completer<String>>[];
  @override
  Future<String> translate(
    String text, {
    required String targetLanguage,
    String? sourceLanguage,
  }) {
    final result = Completer<String>();
    pending.add(result);
    return result.future;
  }
}

void main() {
  for (final dispose in [false, true]) {
    test(
      dispose
          ? 'disposal discards pending translation'
          : 'old completion preserves new request spinner',
      () async {
        var generation = 0;
        final repository = _Repository();
        final translator = _Translator();
        final controller = ChatTranslationController(
          accountId: () => 'account',
          generation: () => generation,
          repository: () => repository,
          settings: () => const TranslationSettingsState(),
          detector: () => _Detector(),
          translator: () => translator,
          targetLocale: () => 'pt',
          defer: (callback) => callback(),
          onError: (error) => fail('$error'),
          supportsOnDeviceTranslation: true,
        );
        final message = MessageItem.text(
          id: 'id',
          senderName: 'sender',
          text: 'hello',
          timestamp: DateTime(2026),
        );
        final old = controller.translate(message, sourceLanguage: 'en');
        if (dispose) {
          controller.dispose();
          translator.pending.single.complete('olá');
          await old;
          expect(repository.saved, isEmpty);
          return;
        }
        generation++;
        controller.reset();
        final current = controller.translate(message, sourceLanguage: 'en');
        translator.pending.first.complete('antigo');
        await old;
        expect(controller.isTranslating(controller.key('id', 'pt')), isTrue);
        expect(repository.saved, isEmpty);
        translator.pending.last.complete('olá');
        await current;
        expect(controller.text(controller.key('id', 'pt'), 'hello'), 'olá');
        expect(repository.saved, hasLength(1));
        controller.dispose();
      },
    );
  }
  test('edited source discards an in-flight translation', () async {
    final repository = _Repository();
    final translator = _Translator();
    final controller = ChatTranslationController(
      accountId: () => 'account',
      generation: () => 0,
      repository: () => repository,
      settings: () => const TranslationSettingsState(),
      detector: () => _Detector(),
      translator: () => translator,
      targetLocale: () => 'pt',
      defer: (callback) => callback(),
      onError: (error) => fail('$error'),
      supportsOnDeviceTranslation: true,
    );
    ChatMessage stored(String body) => ChatMessage(
      messageId: 'id',
      chatId: 'chat',
      senderRecipientId: 'sender',
      body: body,
      createdAt: DateTime(2026),
    );
    controller.hydrate([stored('hello')], 'pt');
    final request = controller.translate(
      MessageItem.text(
        id: 'id',
        senderName: 'sender',
        text: 'hello',
        timestamp: DateTime(2026),
      ),
      sourceLanguage: 'en',
    );
    controller.hydrate([stored('edited')], 'pt');
    translator.pending.single.complete('olá');
    await request;
    expect(repository.saved, isEmpty);
    expect(controller.text(controller.key('id', 'pt'), 'edited'), isNull);
    controller.dispose();
  });
}
