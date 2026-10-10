import 'package:flutter/material.dart';

/// Centralized, type-safe, engineer-grade Bottom Sheet Service according to Google M3 Guidelines.
/// Manages all modal bottom sheets across the entire Tureon application in a unified way.
class AppBottomSheet {
  const AppBottomSheet._();

  /// Displays a generic modal bottom sheet adhering to Material 3 guidelines.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      showDragHandle: showDragHandle,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: builder,
    );
  }

  /// Displays a menu with a list of action tiles.
  static Future<T?> showOptionMenu<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<AppBottomSheetTile> options,
  }) {
    return show<T>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: title,
        subtitle: subtitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options,
        ),
      ),
    );
  }

  /// Displays a competitor-styled E2EE Security & Privacy Modal Bottom Sheet.
  static Future<void> showSecurityModal({
    required BuildContext context,
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onFix,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return show<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isError
                      ? colorScheme.errorContainer.withValues(alpha: 0.6)
                      : colorScheme.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError
                      ? Icons.warning_amber_rounded
                      : Icons.shield_outlined,
                  size: 40,
                  color: isError ? colorScheme.error : colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  _buildSecurityFeatureRow(
                    context,
                    icon: Icons.lock_outline_rounded,
                    title: 'Proteção Signal Protocol',
                    subtitle: 'Codificação de nível militar ativada',
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityFeatureRow(
                    context,
                    icon: Icons.key_outlined,
                    title: 'Chaves Locais Verificadas',
                    subtitle: 'Chaves de criptografia geradas no dispositivo',
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityFeatureRow(
                    context,
                    icon: Icons.visibility_off_outlined,
                    title: 'Privacidade Total',
                    subtitle: 'Nem mesmo o servidor pode ler suas conversas',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (isError && onFix != null) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          onFix.call();
                        },
                        child: const Text('Tentar Inicializar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('OK, Entendi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays an Action Confirmation Bottom Sheet (e.g. Delete, Leave, Logout).
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDestructive = false,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return show<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? colorScheme.errorContainer.withValues(alpha: 0.6)
                      : colorScheme.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isDestructive ? colorScheme.error : colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: Text(cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: isDestructive
                          ? FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                            )
                          : null,
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays an Input Prompt Bottom Sheet with a TextField.
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? initialValue,
    String labelText = '',
    String hintText = '',
    String submitLabel = 'Salvar',
    String cancelLabel = 'Cancelar',
    int maxLength = 32,
  }) {
    final controller = TextEditingController(text: initialValue ?? '');

    return show<String>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: title,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: maxLength,
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) =>
                    Navigator.pop(sheetContext, value.trim()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(cancelLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext, controller.text.trim()),
                    child: Text(submitLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSecurityFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A Material 3 Container for Bottom Sheet content.
class AppBottomSheetContainer extends StatelessWidget {
  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerLeading,
    this.headerTrailing,
    this.showDragHandle = true,
    this.padding,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerLeading;
  final Widget? headerTrailing;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: mediaQuery.viewInsets,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDragHandle)
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Row(
                    children: [
                      if (headerLeading != null) ...[
                        headerLeading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (headerTrailing != null) ...[headerTrailing!],
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ],
              Padding(
                padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Material 3 Bottom Sheet Action Tile
class AppBottomSheetTile extends StatelessWidget {
  const AppBottomSheetTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveColor = isDestructive
        ? colorScheme.error
        : (iconColor ?? colorScheme.onSurfaceVariant);

    final titleColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurface;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? colorScheme.errorContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: effectiveColor,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: titleColor,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
