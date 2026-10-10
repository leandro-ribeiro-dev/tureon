import 'dart:async';
import 'dart:collection';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../domain/translation_repository.dart';
import 'ml_kit_language_detection_repository.dart';
import 'on_device_translation_support.dart';

class MlKitTranslationRepository implements TranslationRepository {
  static final Map<String, Future<void>> _modelDownloads = {};
  static final _translationSlots = _AsyncSemaphore(2);

  MlKitTranslationRepository({MlKitLanguageDetectionRepository? detector})
    : _detector = detector ?? MlKitLanguageDetectionRepository();

  final MlKitLanguageDetectionRepository _detector;
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  @override
  Future<String> translate(
    String text, {
    required String targetLanguage,
    String? sourceLanguage,
  }) => _translationSlots.withPermit(() async {
    if (!supportsOnDeviceTranslation) {
      throw UnsupportedError(
        'On-device translation is supported only on Android and iOS.',
      );
    }
    if (text.trim().isEmpty) return text;

    final sourceCode = sourceLanguage ?? await _detector.identifyLanguage(text);
    final source = BCP47Code.fromRawValue(sourceCode);
    final target = BCP47Code.fromRawValue(targetLanguage);
    if (source == null || target == null) {
      throw UnsupportedError('Unsupported translation language.');
    }
    if (source == target) return text;

    await Future.wait([
      _ensureModel(source.bcpCode),
      _ensureModel(target.bcpCode),
    ]);

    final translator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );
    try {
      return await translator.translateText(text);
    } finally {
      await translator.close();
    }
  });

  Future<void> _ensureModel(String languageCode) {
    return _modelDownloads.putIfAbsent(languageCode, () async {
      try {
        if (await _modelManager.isModelDownloaded(languageCode)) return;
        final downloaded = await _modelManager.downloadModel(
          languageCode,
          isWifiRequired: false,
        );
        if (!downloaded) {
          throw StateError('Could not download the translation model.');
        }
      } catch (_) {
        _modelDownloads.remove(languageCode);
        rethrow;
      }
    });
  }
}

class _AsyncSemaphore {
  _AsyncSemaphore(this.limit);

  final int limit;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();
  int _active = 0;

  Future<T> withPermit<T>(Future<T> Function() operation) async {
    await _acquire();
    try {
      return await operation();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_active < limit) {
      _active++;
      return;
    }
    final waiter = Completer<void>();
    _waiters.addLast(waiter);
    await waiter.future;
  }

  void _release() {
    if (_waiters.isEmpty) {
      _active--;
      return;
    }
    _waiters.removeFirst().complete();
  }
}
