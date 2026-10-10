import 'package:flutter/material.dart';

/// Design system component for grouped, borderless sections with subtle dividers
/// adhering to Clean Architecture and SRP guidelines in AGENTS.md.
class AppSectionGroup extends StatelessWidget {
  const AppSectionGroup({
    super.key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (children.isEmpty) return const SizedBox.shrink();

    final List<Widget> separated = [];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        );
      }
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
          ...separated,
        ],
      ),
    );
  }
}
