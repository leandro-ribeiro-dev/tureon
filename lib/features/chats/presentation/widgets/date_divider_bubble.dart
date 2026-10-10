import 'package:flutter/material.dart';

/// Competitor-styled Date Divider Pill (e.g. "Hoje", "Ontem", "10/09", "10/09/2024").
/// Renders a centered pill badge in the conversation list whenever the calendar day changes.
class DateDividerBubble extends StatelessWidget {
  const DateDividerBubble({super.key, required this.date});

  final DateTime date;

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return 'Hoje';
    } else if (msgDate == yesterday) {
      return 'Ontem';
    } else if (msgDate.year == now.year) {
      // Formats as DD/MM
      final day = msgDate.day.toString().padLeft(2, '0');
      final month = msgDate.month.toString().padLeft(2, '0');
      return '$day/$month';
    } else {
      // Formats as DD/MM/AAAA
      final day = msgDate.day.toString().padLeft(2, '0');
      final month = msgDate.month.toString().padLeft(2, '0');
      return '$day/$month/${msgDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = _formatDateLabel(date);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
