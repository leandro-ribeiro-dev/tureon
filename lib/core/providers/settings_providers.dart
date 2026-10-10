import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_runtime.dart';
import '../storage/message_records.dart';
import '../../features/chats/data/ml_kit_language_detection_repository.dart';
import '../../features/chats/data/ml_kit_translation_repository.dart';
import '../../features/chats/domain/language_detection_repository.dart';
import '../../features/chats/domain/translation_repository.dart';

final appRuntimeProvider = Provider<AppRuntime?>((ref) => null);

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() =>
      switch (ref.watch(appRuntimeProvider)?.loadSetting('theme_mode')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(appRuntimeProvider)?.saveSetting('theme_mode', mode.name);
  }
}

final appThemeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);

class MessageBubbleRadiusNotifier extends Notifier<double> {
  @override
  double build() {
    final stored = ref.watch(appRuntimeProvider)?.loadSetting('message_radius');
    return (double.tryParse(stored ?? '') ?? 16).clamp(0, 28).toDouble();
  }

  void setRadius(double radius) {
    state = radius.clamp(0, 28).toDouble();
    ref.read(appRuntimeProvider)?.saveSetting('message_radius', '$state');
  }
}

final messageBubbleRadiusProvider =
    NotifierProvider<MessageBubbleRadiusNotifier, double>(
      MessageBubbleRadiusNotifier.new,
    );

final activeSessionProvider = StreamProvider.autoDispose<UserSession?>((ref) {
  final runtime = ref.watch(appRuntimeProvider);
  if (runtime == null) return Stream.value(null);
  return runtime.watchSession();
});

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return MlKitTranslationRepository();
});

final messageLanguageDetectorProvider = Provider<MessageLanguageDetector>((
  ref,
) {
  return MlKitLanguageDetectionRepository();
});

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final runtime = ref.watch(appRuntimeProvider);
    return _readLocale(runtime);
  }

  static Locale _readLocale(AppRuntime? runtime) {
    final stored = runtime?.loadSetting('app_locale');
    if (stored == null) return const Locale('pt', 'BR');
    final parts = stored.split('_');
    return Locale(parts.first, parts.length > 1 ? parts[1] : null);
  }

  void setLocale(Locale locale) {
    state = locale;
    ref
        .read(appRuntimeProvider)
        ?.saveSetting(
          'app_locale',
          [
            locale.languageCode,
            locale.countryCode,
          ].whereType<String>().join('_'),
        );
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class TranslationSettingsState {
  const TranslationSettingsState({
    this.isTranslationEnabled = false,
    this.doNotTranslateLanguages = const {},
  });

  final bool isTranslationEnabled;
  final Set<String> doNotTranslateLanguages;

  TranslationSettingsState copyWith({
    bool? isTranslationEnabled,
    Set<String>? doNotTranslateLanguages,
  }) => TranslationSettingsState(
    isTranslationEnabled: isTranslationEnabled ?? this.isTranslationEnabled,
    doNotTranslateLanguages:
        doNotTranslateLanguages ?? this.doNotTranslateLanguages,
  );
}

class TranslationSettingsNotifier extends Notifier<TranslationSettingsState> {
  @override
  TranslationSettingsState build() {
    final runtime = ref.watch(appRuntimeProvider);
    return _readSettings(runtime);
  }

  static TranslationSettingsState _readSettings(AppRuntime? runtime) {
    final stored = runtime?.loadSetting('message_translation');
    if (stored == null) return const TranslationSettingsState();
    try {
      final data = jsonDecode(stored) as Map<String, dynamic>;
      return TranslationSettingsState(
        isTranslationEnabled: data['enabled'] as bool? ?? false,
        doNotTranslateLanguages:
            (data['ignored'] as List<dynamic>?)?.cast<String>().toSet() ??
            const {},
      );
    } on FormatException {
      return const TranslationSettingsState();
    }
  }

  void _save(TranslationSettingsState value) {
    ref
        .read(appRuntimeProvider)
        ?.saveSetting(
          'message_translation',
          jsonEncode({
            'enabled': value.isTranslationEnabled,
            'ignored': value.doNotTranslateLanguages.toList(),
          }),
        );
  }

  void toggleTranslation(bool enabled) {
    state = state.copyWith(isTranslationEnabled: enabled);
    _save(state);
  }

  void addDoNotTranslateLanguage(String langCode) {
    state = state.copyWith(
      doNotTranslateLanguages: {...state.doNotTranslateLanguages, langCode},
    );
    _save(state);
  }

  void removeDoNotTranslateLanguage(String langCode) {
    state = state.copyWith(
      doNotTranslateLanguages: {...state.doNotTranslateLanguages}
        ..remove(langCode),
    );
    _save(state);
  }
}

final translationSettingsProvider =
    NotifierProvider<TranslationSettingsNotifier, TranslationSettingsState>(
      TranslationSettingsNotifier.new,
    );

class ReduceVisualEffectsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final runtime = ref.watch(appRuntimeProvider);
    return runtime?.loadSetting('reduce_visual_effects') == 'true';
  }

  void toggle(bool value) {
    state = value;
    ref
        .read(appRuntimeProvider)
        ?.saveSetting('reduce_visual_effects', value.toString());
  }
}

final reduceVisualEffectsProvider =
    NotifierProvider<ReduceVisualEffectsNotifier, bool>(
      ReduceVisualEffectsNotifier.new,
    );

class SettingsValuesNotifier extends Notifier<Map<String, Object?>> {
  @override
  Map<String, Object?> build() {
    final runtime = ref.watch(appRuntimeProvider);
    return _readValues(runtime);
  }

  static Map<String, Object?> _readValues(AppRuntime? runtime) {
    final stored = runtime?.loadSetting('settings_values');
    if (stored == null) return {};
    try {
      return (jsonDecode(stored) as Map<String, dynamic>)
          .cast<String, Object?>();
    } on FormatException {
      return {};
    }
  }

  void setValue(String id, Object? value) {
    state = {...state, id: value};
    ref
        .read(appRuntimeProvider)
        ?.saveSetting('settings_values', jsonEncode(state));
  }
}

final settingsValuesProvider =
    NotifierProvider<SettingsValuesNotifier, Map<String, Object?>>(
      SettingsValuesNotifier.new,
    );

class ChatFoldersNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    final runtime = ref.watch(appRuntimeProvider);
    return _readFolders(runtime);
  }

  static Map<String, String> _readFolders(AppRuntime? runtime) {
    final stored = runtime?.loadSetting('chat_folders');
    if (stored == null) return {};
    try {
      return (jsonDecode(stored) as Map<String, dynamic>)
          .cast<String, String>();
    } on FormatException {
      return {};
    }
  }

  void _save() => ref
      .read(appRuntimeProvider)
      ?.saveSetting('chat_folders', jsonEncode(state));

  void add(String name) {
    final id = 'folder_${DateTime.now().microsecondsSinceEpoch}';
    state = {...state, id: name};
    _save();
  }

  void rename(String id, String name) {
    state = {...state, id: name};
    _save();
  }

  void remove(String id) {
    state = {...state}..remove(id);
    _save();
  }
}

final chatFoldersProvider =
    NotifierProvider<ChatFoldersNotifier, Map<String, String>>(
      ChatFoldersNotifier.new,
    );

class ChatFilterTab {
  const ChatFilterTab({
    required this.id,
    required this.label,
    required this.filterType,
    this.isEnabled = true,
    this.isBuiltIn = true,
    this.customRecipientIds = const [],
  });

  final String id;
  final String label;
  final String filterType;
  final bool isEnabled;
  final bool isBuiltIn;
  final List<String> customRecipientIds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'filterType': filterType,
    'isEnabled': isEnabled,
    'isBuiltIn': isBuiltIn,
    'customRecipientIds': customRecipientIds,
  };

  factory ChatFilterTab.fromJson(Map<String, dynamic> json) => ChatFilterTab(
    id: json['id'] as String,
    label: json['label'] as String,
    filterType: json['filterType'] as String? ?? 'custom',
    isEnabled: json['isEnabled'] as bool? ?? true,
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    customRecipientIds:
        (json['customRecipientIds'] as List<dynamic>?)?.cast<String>() ??
        const [],
  );

  ChatFilterTab copyWith({
    String? id,
    String? label,
    String? filterType,
    bool? isEnabled,
    bool? isBuiltIn,
    List<String>? customRecipientIds,
  }) {
    return ChatFilterTab(
      id: id ?? this.id,
      label: label ?? this.label,
      filterType: filterType ?? this.filterType,
      isEnabled: isEnabled ?? this.isEnabled,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      customRecipientIds: customRecipientIds ?? this.customRecipientIds,
    );
  }
}

class ChatFilterTabsNotifier extends Notifier<List<ChatFilterTab>> {
  @override
  List<ChatFilterTab> build() {
    final runtime = ref.watch(appRuntimeProvider);
    return _readTabs(runtime);
  }

  static List<ChatFilterTab> defaultTabs() => const [
    ChatFilterTab(
      id: 'all',
      label: 'Tudo',
      filterType: 'all',
      isBuiltIn: true,
      isEnabled: true,
    ),
    ChatFilterTab(
      id: 'favorites',
      label: 'Favoritos',
      filterType: 'favorites',
      isBuiltIn: true,
      isEnabled: true,
    ),
    ChatFilterTab(
      id: 'unread',
      label: 'Não lidas',
      filterType: 'unread',
      isBuiltIn: true,
      isEnabled: true,
    ),
    ChatFilterTab(
      id: 'groups',
      label: 'Grupos',
      filterType: 'groups',
      isBuiltIn: true,
      isEnabled: true,
    ),
    ChatFilterTab(
      id: 'channels',
      label: 'Canais',
      filterType: 'channels',
      isBuiltIn: true,
      isEnabled: true,
    ),
    ChatFilterTab(
      id: 'contacts',
      label: 'Privados',
      filterType: 'contacts',
      isBuiltIn: true,
      isEnabled: false,
    ),
  ];

  static List<ChatFilterTab> _readTabs(AppRuntime? runtime) {
    final stored = runtime?.loadSetting('chat_filter_tabs');
    if (stored == null) return defaultTabs();
    try {
      final list = jsonDecode(stored) as List<dynamic>;
      if (list.isEmpty) return defaultTabs();
      return list
          .map((item) => ChatFilterTab.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return defaultTabs();
    }
  }

  void _save() {
    ref
        .read(appRuntimeProvider)
        ?.saveSetting(
          'chat_filter_tabs',
          jsonEncode(state.map((t) => t.toJson()).toList()),
        );
  }

  void toggleEnabled(String tabId, bool isEnabled) {
    state = state
        .map((t) => t.id == tabId ? t.copyWith(isEnabled: isEnabled) : t)
        .toList();
    _save();
  }

  void addTab(ChatFilterTab tab) {
    state = [...state, tab];
    _save();
  }

  void updateTab(ChatFilterTab tab) {
    state = state.map((t) => t.id == tab.id ? tab : t).toList();
    _save();
  }

  void removeTab(String tabId) {
    state = state.where((t) => t.id != tabId).toList();
    _save();
  }

  void reorderTabs(int oldIndex, int newIndex) {
    final list = List<ChatFilterTab>.from(state);
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _save();
  }

  void resetToDefault() {
    state = defaultTabs();
    _save();
  }
}

final chatFilterTabsProvider =
    NotifierProvider<ChatFilterTabsNotifier, List<ChatFilterTab>>(
      ChatFilterTabsNotifier.new,
    );

class ShowFilterChipsRowNotifier extends Notifier<bool> {
  @override
  bool build() {
    final runtime = ref.watch(appRuntimeProvider);
    final stored = runtime?.loadSetting('show_filter_chips_row');
    return stored != 'false';
  }

  void toggle(bool value) {
    state = value;
    ref
        .read(appRuntimeProvider)
        ?.saveSetting('show_filter_chips_row', value.toString());
  }
}

final showFilterChipsRowProvider =
    NotifierProvider<ShowFilterChipsRowNotifier, bool>(
      ShowFilterChipsRowNotifier.new,
    );

class ShowFilterUnreadBadgesNotifier extends Notifier<bool> {
  @override
  bool build() {
    final runtime = ref.watch(appRuntimeProvider);
    final stored = runtime?.loadSetting('show_filter_unread_badges');
    return stored != 'false';
  }

  void toggle(bool value) {
    state = value;
    ref
        .read(appRuntimeProvider)
        ?.saveSetting('show_filter_unread_badges', value.toString());
  }
}

final showFilterUnreadBadgesProvider =
    NotifierProvider<ShowFilterUnreadBadgesNotifier, bool>(
      ShowFilterUnreadBadgesNotifier.new,
    );
