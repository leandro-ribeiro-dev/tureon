import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../../../core/providers/settings_providers.dart'
    show TranslationSettingsState;
import '../../../../core/protocol/protocol_models.dart';
import '../../domain/chat_message.dart' as chat_domain;
import '../../domain/chat_repository.dart';
import '../../domain/message_translation.dart';
import '../../domain/translation_repository.dart';
import '../../domain/language_detection_repository.dart';

/// Owns local translation caches and the bounded automatic-translation queue.
/// Dependencies are injected; no widget, RPC or cryptographic key is accessed.
class ChatTranslationController extends ChangeNotifier {
  ChatTranslationController({
    required this.accountId,
    required this.generation,
    required this.repository,
    required this.settings,
    required this.detector,
    required this.translator,
    required this.targetLocale,
    required this.defer,
    required this.onError,
    required this.supportsOnDeviceTranslation,
  });
  final String? Function() accountId;
  final int Function() generation;
  final ChatRepository? Function() repository;
  final TranslationSettingsState Function() settings;
  final MessageLanguageDetector Function() detector;
  final TranslationRepository Function() translator;
  final String Function() targetLocale;
  final void Function(VoidCallback) defer;
  final void Function(Object) onError;
  final bool supportsOnDeviceTranslation;
  bool _disposed = false;
  bool get isActive => !_disposed;
  void _update(VoidCallback update) {
    if (_disposed) return;
    update();
    notifyListeners();
  }

  /// Map of messageId -> translatedText
  final Map<String, String> _translations = {};

  /// Map of messageId -> sourceLanguage
  final Map<String, String> _sourceLanguages = {};

  /// Map of messageId -> isShowingOriginal
  final Map<String, bool> _showingOriginalMap = {};
  final Map<String, String> _translationSourceTexts = {};
  final Map<String, String> _observedSourceBodies = {};
  final Set<String> _translatingMessages = {};
  final Map<String, Object> _activeRequests = {};
  final Set<String> _translationCacheLoaded = {};
  final Set<String> _automaticTranslationAttempted = {};
  final Queue<({MessageItem message, String targetLanguage, int generation})>
  _automaticTranslationQueue = Queue();
  final Set<String> _queuedAutomaticTranslations = {};
  int _activeAutomaticTranslations = 0;

  String key(String messageId, String language) =>
      _translationKey(messageId, language);
  String? text(String key, String source) =>
      _translationSourceTexts[key] == source ? _translations[key] : null;
  String? sourceLanguage(String key) => _sourceLanguages[key];
  bool isTranslating(String key) => _translatingMessages.contains(key);
  bool showsOriginal(String key) => _showingOriginalMap[key] ?? false;
  void toggleOriginal(String key) =>
      _update(() => _showingOriginalMap[key] = !showsOriginal(key));
  void reset() {
    _translations.clear();
    _sourceLanguages.clear();
    _showingOriginalMap.clear();
    _translationSourceTexts.clear();
    _observedSourceBodies.clear();
    _translatingMessages.clear();
    _activeRequests.clear();
    _translationCacheLoaded.clear();
    _automaticTranslationAttempted.clear();
    _automaticTranslationQueue.clear();
    _queuedAutomaticTranslations.clear();
  }

  @override
  void dispose() {
    _disposed = true;
    reset();
    super.dispose();
  }

  String _translationKey(String messageId, String targetLanguage) =>
      '${accountId() ?? 'local'}:$targetLanguage:$messageId';

  String _translationSourceKey(String messageId) =>
      '${accountId() ?? 'local'}:$messageId';

  bool _isCurrentTranslationRequest(
    int requestGeneration,
    String? requestAccountId,
  ) =>
      isActive &&
      requestGeneration == generation() &&
      requestAccountId == accountId();

  bool _isCurrentSourceRequest(
    int generation,
    String? account,
    String messageId,
    String source,
  ) =>
      _isCurrentTranslationRequest(generation, account) &&
      (_observedSourceBodies[_translationSourceKey(messageId)] == null ||
          _observedSourceBodies[_translationSourceKey(messageId)] == source);

  void hydrate(List<chat_domain.ChatMessage> messages, String targetLanguage) {
    _trackTranslationSourceBodies(messages);
    final localRepository = repository();
    if (localRepository == null || messages.isEmpty) return;
    final messageIds = <String>[];
    for (final message in messages) {
      if (message.senderRecipientId == accountId() ||
          message.type == chat_domain.ChatMessageType.system) {
        continue;
      }
      final key = _translationKey(message.messageId, targetLanguage);
      if (_translationCacheLoaded.add(key)) messageIds.add(message.messageId);
    }
    if (messageIds.isEmpty) return;
    final requestGeneration = generation();
    final requestAccountId = accountId();
    final sourceBodies = {
      for (final message in messages) message.messageId: message.body,
    };
    defer(() {
      if (!isActive ||
          requestGeneration != generation() ||
          requestAccountId != accountId()) {
        return;
      }
      try {
        final cached = localRepository.loadMessageTranslations(
          messageIds,
          targetLanguage: targetLanguage,
        );
        if (cached.isEmpty) return;
        _update(() {
          for (final entry in cached.entries) {
            if (entry.value.sourceText != sourceBodies[entry.key] ||
                _observedSourceBodies[_translationSourceKey(entry.key)] !=
                    sourceBodies[entry.key]) {
              continue;
            }
            final key = _translationKey(entry.key, targetLanguage);
            _translations[key] = entry.value.translatedText;
            _sourceLanguages[key] = entry.value.sourceLanguage;
            _translationSourceTexts[key] = entry.value.sourceText;
            _showingOriginalMap[key] = false;
          }
        });
      } catch (error, stackTrace) {
        for (final messageId in messageIds) {
          _translationCacheLoaded.remove(
            _translationKey(messageId, targetLanguage),
          );
        }
        developer.log(
          'Could not load local message translations',
          name: 'tureon.translation',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
  }

  void _trackTranslationSourceBodies(List<chat_domain.ChatMessage> messages) {
    final accountPrefix = '${accountId() ?? 'local'}:';
    for (final message in messages) {
      final sourceKey = _translationSourceKey(message.messageId);
      final previousBody = _observedSourceBodies[sourceKey];
      if (previousBody != null && previousBody != message.body) {
        bool belongsToMessage(String key) =>
            key.startsWith(accountPrefix) &&
            key.endsWith(':${message.messageId}');
        _translations.removeWhere((key, _) => belongsToMessage(key));
        _sourceLanguages.removeWhere((key, _) => belongsToMessage(key));
        _translationSourceTexts.removeWhere((key, _) => belongsToMessage(key));
        _showingOriginalMap.removeWhere((key, _) => belongsToMessage(key));
        _translationCacheLoaded.removeWhere(belongsToMessage);
        _automaticTranslationAttempted.removeWhere(belongsToMessage);
        _queuedAutomaticTranslations.removeWhere(belongsToMessage);
        _automaticTranslationQueue.removeWhere(
          (request) => request.message.id == message.messageId,
        );
      }
      _observedSourceBodies[sourceKey] = message.body;
    }
  }

  void queueAutomatic(MessageItem message, String targetLanguage) {
    if (message.text == null || message.text!.trim().isEmpty) return;
    final key = _translationKey(message.id, targetLanguage);
    if (_translations.containsKey(key) ||
        _translatingMessages.contains(key) ||
        _automaticTranslationAttempted.contains(key) ||
        !_queuedAutomaticTranslations.add(key)) {
      return;
    }
    _automaticTranslationAttempted.add(key);
    _automaticTranslationQueue.add((
      message: message,
      targetLanguage: targetLanguage,
      generation: generation(),
    ));
    _drainAutomaticTranslationQueue();
  }

  void _drainAutomaticTranslationQueue() {
    while (_activeAutomaticTranslations < 2 &&
        _automaticTranslationQueue.isNotEmpty) {
      final request = _automaticTranslationQueue.removeFirst();
      final key = _translationKey(request.message.id, request.targetLanguage);
      _queuedAutomaticTranslations.remove(key);
      if (request.generation != generation()) continue;
      _activeAutomaticTranslations++;
      unawaited(
        translate(
          request.message,
          targetLanguage: request.targetLanguage,
          automatic: true,
        ).whenComplete(() {
          if (isActive && !settings().isTranslationEnabled) {
            _automaticTranslationAttempted.remove(key);
          }
          _activeAutomaticTranslations--;
          _drainAutomaticTranslationQueue();
        }),
      );
    }
  }

  Future<void> translate(
    MessageItem message, {
    String? sourceLanguage,
    String? targetLanguage,
    bool automatic = false,
  }) async {
    final text = message.text;
    final conversationGeneration = generation();
    final requestAccountId = accountId();
    final destination = targetLanguage ?? targetLocale();
    final settingsAtStart = settings();
    final key = _translationKey(message.id, destination);
    if (text == null ||
        text.trim().isEmpty ||
        _translatingMessages.contains(key)) {
      return;
    }

    final requestToken = Object();
    _activeRequests[key] = requestToken;
    _translatingMessages.add(key);
    if (isActive) _update(() {});
    try {
      final currentSettings = settings();
      if (automatic && !currentSettings.isTranslationEnabled) return;
      final localRepository = repository();
      if (localRepository == null) {
        throw StateError(
          'A local chat repository is required for translation.',
        );
      }
      if (!_isCurrentSourceRequest(
        conversationGeneration,
        requestAccountId,
        message.id,
        text,
      )) {
        return;
      }
      final saved = localRepository.loadMessageTranslations([
        message.id,
      ], targetLanguage: destination)[message.id];
      if (saved != null && saved.sourceText == text) {
        if (!_isCurrentSourceRequest(
          conversationGeneration,
          requestAccountId,
          message.id,
          text,
        )) {
          return;
        }
        _update(() {
          _translations[key] = saved.translatedText;
          _sourceLanguages[key] = saved.sourceLanguage;
          _translationSourceTexts[key] = saved.sourceText;
          _showingOriginalMap[key] = false;
        });
        return;
      }
      if (!supportsOnDeviceTranslation) {
        throw UnsupportedError(
          'On-device translation is supported only on Android and iOS.',
        );
      }
      final languageDetector = detector();
      final detectedLanguage =
          sourceLanguage ?? await languageDetector.identifyLanguage(text);
      if (!_isCurrentSourceRequest(
        conversationGeneration,
        requestAccountId,
        message.id,
        text,
      )) {
        return;
      }
      if (detectedLanguage == 'und' ||
          detectedLanguage == destination ||
          (automatic &&
              currentSettings.doNotTranslateLanguages.contains(
                detectedLanguage,
              ))) {
        return;
      }

      final translated = await translator().translate(
        text,
        targetLanguage: destination,
        sourceLanguage: detectedLanguage,
      );
      if (!_isCurrentSourceRequest(
        conversationGeneration,
        requestAccountId,
        message.id,
        text,
      )) {
        return;
      }

      if (automatic && !settings().isTranslationEnabled) {
        return;
      }
      final persisted = await localRepository.saveMessageTranslation(
        MessageTranslation(
          messageId: message.id,
          sourceText: text,
          targetLanguage: destination,
          sourceLanguage: detectedLanguage,
          translatedText: translated,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      if (!persisted ||
          !_isCurrentSourceRequest(
            conversationGeneration,
            requestAccountId,
            message.id,
            text,
          )) {
        return;
      }

      _update(() {
        _translations[key] = translated;
        _sourceLanguages[key] = detectedLanguage;
        _translationSourceTexts[key] = text;
        _showingOriginalMap[key] = false;
      });
    } catch (error, stackTrace) {
      developer.log(
        'Could not translate message on this device',
        name: 'tureon.translation',
        error: error,
        stackTrace: stackTrace,
      );
      if (!automatic &&
          _isCurrentSourceRequest(
            conversationGeneration,
            requestAccountId,
            message.id,
            text,
          )) {
        onError(error);
      }
    } finally {
      if (identical(_activeRequests[key], requestToken)) {
        _activeRequests.remove(key);
        _translatingMessages.remove(key);
      }
      if (automatic && isActive && !identical(settings(), settingsAtStart)) {
        _automaticTranslationAttempted.remove(key);
      }
      if (isActive) _update(() {});
    }
  }
}
