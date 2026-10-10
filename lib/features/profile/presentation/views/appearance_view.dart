import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/settings_providers.dart';

class AppearanceView extends ConsumerWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(appThemeModeProvider);
    final radius = ref.watch(messageBubbleRadiusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Aparência e tema')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Tema', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.wb_sunny_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Noite'),
                icon: Icon(Icons.nightlight_outlined),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => ref
                .read(appThemeModeProvider.notifier)
                .setThemeMode(selection.first),
          ),
          const SizedBox(height: 28),
          Text('Bordas da conversa', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Ajuste o arredondamento dos balões e veja o resultado em tempo real.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  const Text('Quadrado'),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 28,
                      divisions: 7,
                      value: radius,
                      label: '${radius.round()} px',
                      onChanged: ref
                          .read(messageBubbleRadiusProvider.notifier)
                          .setRadius,
                    ),
                  ),
                  const Text('Redondo'),
                ],
              ),
              const SizedBox(height: 12),
              _Preview(radius: radius),
            ],
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: const Text('Uma mensagem recebida'),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Text(
              'Sua mensagem',
              style: TextStyle(color: colors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
