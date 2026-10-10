import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/settings_providers.dart';
import '../../../../l10n/app_localizations_extensions.dart';
import '../../../chats/data/on_device_translation_support.dart';

class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  final String code;
  final String name;
  final String nativeName;
  final String flag;
}

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  final TextEditingController _uiLanguageSearchController =
      TextEditingController();
  final TextEditingController _translationLanguageSearchController =
      TextEditingController();
  String _uiLanguageSearch = '';
  String _translationLanguageSearch = '';

  static const List<SupportedLanguage> _allLanguages = [
    SupportedLanguage(
      code: 'pt',
      name: 'Português',
      nativeName: 'Português (Brasil)',
      flag: '🇧🇷',
    ),
    SupportedLanguage(
      code: 'en',
      name: 'Inglês',
      nativeName: 'English (US)',
      flag: '🇺🇸',
    ),
    SupportedLanguage(
      code: 'es',
      name: 'Espanhol',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    SupportedLanguage(
      code: 'de',
      name: 'Alemão',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    SupportedLanguage(
      code: 'fr',
      name: 'Francês',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    SupportedLanguage(
      code: 'it',
      name: 'Italiano',
      nativeName: 'Italiano',
      flag: '🇮🇹',
    ),
    SupportedLanguage(
      code: 'ja',
      name: 'Japonês',
      nativeName: '日本語',
      flag: '🇯🇵',
    ),
    SupportedLanguage(
      code: 'zh',
      name: 'Chinês',
      nativeName: '中文',
      flag: '🇨🇳',
    ),
    SupportedLanguage(
      code: 'ru',
      name: 'Russo',
      nativeName: 'Русский',
      flag: '🇷🇺',
    ),
    SupportedLanguage(
      code: 'ar',
      name: 'Árabe',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
  ];

  static const Set<String> _appLanguageCodes = {'pt', 'en', 'es'};

  @override
  void dispose() {
    _uiLanguageSearchController.dispose();
    _translationLanguageSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.safeLocalizations;
    final currentLocale = ref.watch(appLocaleProvider);
    final translationSettings = ref.watch(translationSettingsProvider);
    final translationNotifier = ref.read(translationSettingsProvider.notifier);
    final currentCode = currentLocale.languageCode;

    String languageName(SupportedLanguage language) => switch (language.code) {
      'pt' => l10n.languagePortuguese,
      'en' => l10n.languageEnglish,
      'es' => l10n.languageSpanish,
      'de' => l10n.languageGerman,
      'fr' => l10n.languageFrench,
      'it' => l10n.languageItalian,
      'ja' => l10n.languageJapanese,
      'zh' => l10n.languageChinese,
      'ru' => l10n.languageRussian,
      'ar' => l10n.languageArabic,
      _ => language.name,
    };

    final appLanguages = _allLanguages
        .where((language) => _appLanguageCodes.contains(language.code))
        .where(
          (language) =>
              _matchesSearch(language, _uiLanguageSearch, languageName),
        )
        .toList(growable: false);
    final translationLanguages = _allLanguages
        .where(
          (language) => _matchesSearch(
            language,
            _translationLanguageSearch,
            languageName,
          ),
        )
        .toList(growable: false);
    final selectedLanguage = _allLanguages
        .where((language) => language.code == currentCode)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageSettingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              l10n.appLanguageSection,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _CurrentLanguageCard(
              language: selectedLanguage,
              currentCode: currentCode,
              languageName: selectedLanguage == null
                  ? currentCode.toUpperCase()
                  : languageName(selectedLanguage),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _uiLanguageSearchController,
              onChanged: (value) => setState(() => _uiLanguageSearch = value),
              decoration: InputDecoration(
                hintText: l10n.searchAppLanguage,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _uiLanguageSearch.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        onPressed: () {
                          _uiLanguageSearchController.clear();
                          setState(() => _uiLanguageSearch = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.appLanguageSection} · ${appLanguages.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (appLanguages.isEmpty)
              _EmptySearchResult(color: colors.onSurfaceVariant)
            else
              ...appLanguages.map((language) {
                final selected = language.code == currentCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LanguageOption(
                    language: language,
                    title: languageName(language),
                    selected: selected,
                    onTap: () {
                      if (selected) return;
                      ref
                          .read(appLocaleProvider.notifier)
                          .setLocale(Locale(language.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.uiLanguageChanged(languageName(language)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            const SizedBox(height: 24),
            Divider(color: colors.outlineVariant.withValues(alpha: 0.65)),
            const SizedBox(height: 16),
            _TranslationSettingsCard(
              enabled: translationSettings.isTranslationEnabled,
              ignoredLanguages: translationSettings.doNotTranslateLanguages,
              languages: translationLanguages,
              languageName: languageName,
              searchController: _translationLanguageSearchController,
              searchQuery: _translationLanguageSearch,
              onSearchChanged: (value) => setState(() {
                _translationLanguageSearch = value;
                if (value.isEmpty) _translationLanguageSearchController.clear();
              }),
              onEnabledChanged: translationNotifier.toggleTranslation,
              onLanguageToggled: (language, ignored) {
                if (ignored) {
                  translationNotifier.addDoNotTranslateLanguage(language);
                } else {
                  translationNotifier.removeDoNotTranslateLanguage(language);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesSearch(
    SupportedLanguage language,
    String query,
    String Function(SupportedLanguage) languageName,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    return languageName(language).toLowerCase().contains(normalizedQuery) ||
        language.nativeName.toLowerCase().contains(normalizedQuery) ||
        language.code.toLowerCase().contains(normalizedQuery);
  }
}

class _CurrentLanguageCard extends StatelessWidget {
  const _CurrentLanguageCard({
    required this.language,
    required this.currentCode,
    required this.languageName,
  });

  final SupportedLanguage? language;
  final String currentCode;
  final String languageName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: colors.surface,
            child: Text(
              language?.flag ?? '🌐',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  language?.nativeName ?? currentCode.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: colors.primary),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final SupportedLanguage language;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Semantics(
          button: true,
          selected: selected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: colors.surface,
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 19),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language.nativeName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? colors.primary : colors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslationSettingsCard extends StatelessWidget {
  const _TranslationSettingsCard({
    required this.enabled,
    required this.ignoredLanguages,
    required this.languages,
    required this.languageName,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onEnabledChanged,
    required this.onLanguageToggled,
  });

  final bool enabled;
  final Set<String> ignoredLanguages;
  final List<SupportedLanguage> languages;
  final String Function(SupportedLanguage) languageName;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onEnabledChanged;
  final void Function(String languageCode, bool ignored) onLanguageToggled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.safeLocalizations;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.translate_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.messageTranslationSection,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.translateMessages),
              subtitle: Text(
                supportsOnDeviceTranslation
                    ? l10n.translateMessagesHint
                    : l10n.translationUnavailable,
              ),
              value: enabled,
              onChanged: onEnabledChanged,
            ),
            if (enabled) ...[
              const SizedBox(height: 8),
              Text(
                l10n.understoodLanguages,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.understoodLanguagesHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchMessageLanguage,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).deleteButtonTooltip,
                          onPressed: () => onSearchChanged(''),
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language in languages)
                    FilterChip(
                      avatar: Text(language.flag),
                      label: Text(languageName(language)),
                      selected: ignoredLanguages.contains(language.code),
                      onSelected: (ignored) =>
                          onLanguageToggled(language.code, ignored),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(
        context.safeLocalizations.languageNoResults,
        style: TextStyle(color: color),
      ),
    ),
  );
}
