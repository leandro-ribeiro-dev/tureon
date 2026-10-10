import 'package:flutter/material.dart';

class FilterChipItem {
  final String id;
  final String label;
  final int unreadCount;

  const FilterChipItem({
    required this.id,
    required this.label,
    this.unreadCount = 0,
  });
}

class ChatsFilterChipsRow extends StatelessWidget {
  const ChatsFilterChipsRow({
    super.key,
    this.options,
    this.items,
    required this.selectedFilter,
    required this.onSelected,
  });

  final List<String>? options;
  final List<FilterChipItem>? items;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg = theme.colorScheme.primaryContainer;
    final selectedFg = theme.colorScheme.onPrimaryContainer;
    final unselectedBg = isDark
        ? const Color(0xFF232D36)
        : theme.colorScheme.surfaceContainerHigh;
    final unselectedFg = theme.colorScheme.onSurfaceVariant;

    final chipList =
        items ??
        (options?.map((opt) => FilterChipItem(id: opt, label: opt)).toList() ??
            const []);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: chipList.map((chip) {
          final isSelected =
              selectedFilter == chip.id || selectedFilter == chip.label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chip.label,
                    style: TextStyle(
                      color: isSelected ? selectedFg : unselectedFg,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (chip.unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedFg
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${chip.unreadCount}',
                        style: TextStyle(
                          color: isSelected
                              ? selectedBg
                              : theme.colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: selectedBg,
              backgroundColor: unselectedBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                if (selected) {
                  onSelected(chip.id);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
