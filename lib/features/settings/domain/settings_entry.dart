import 'package:flutter/material.dart';

enum SettingsEntryType { navigation, toggle, selector, action }

/// Declarative entry for settings items avoiding repetitive UI code and hardcoded colors.
class SettingsEntry {
  const SettingsEntry({
    required this.id,
    required this.icon,
    required this.titleKey,
    this.subtitleKey,
    this.type = SettingsEntryType.navigation,
    this.route,
    this.valueProviderKey,
    this.currentValue,
    this.options,
    this.isDestructive = false,
    this.onToggleChanged,
    this.onTap,
  });

  final String id;
  final IconData icon;
  final String titleKey;
  final String? subtitleKey;
  final SettingsEntryType type;
  final String? route;
  final String? valueProviderKey;
  final dynamic currentValue;
  final List<String>? options;
  final bool isDestructive;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;

  SettingsEntry copyWith({
    String? id,
    IconData? icon,
    String? titleKey,
    String? subtitleKey,
    SettingsEntryType? type,
    String? route,
    String? valueProviderKey,
    dynamic currentValue,
    List<String>? options,
    bool? isDestructive,
    ValueChanged<bool>? onToggleChanged,
    VoidCallback? onTap,
  }) {
    return SettingsEntry(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      titleKey: titleKey ?? this.titleKey,
      subtitleKey: subtitleKey ?? this.subtitleKey,
      type: type ?? this.type,
      route: route ?? this.route,
      valueProviderKey: valueProviderKey ?? this.valueProviderKey,
      currentValue: currentValue ?? this.currentValue,
      options: options ?? this.options,
      isDestructive: isDestructive ?? this.isDestructive,
      onToggleChanged: onToggleChanged ?? this.onToggleChanged,
      onTap: onTap ?? this.onTap,
    );
  }
}

/// Represents a group section of settings.
class SettingsSection {
  const SettingsSection({
    required this.id,
    required this.titleKey,
    this.subtitle,
    required this.entries,
  });

  final String id;
  final String titleKey;
  final String? subtitle;
  final List<SettingsEntry> entries;
}
