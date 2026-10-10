import 'package:flutter/material.dart';

/// Design system component for displaying shared media, links, and documents
/// in Profile views adhering to Clean Architecture and SRP in AGENTS.md.
class SharedMediaShowcase extends StatelessWidget {
  const SharedMediaShowcase({
    super.key,
    this.mediaUrls = const [],
    this.totalCount = 0,
    this.onViewAll,
  });

  final List<String> mediaUrls;
  final int totalCount;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Media placeholders or real items
    final items = mediaUrls.isNotEmpty
        ? mediaUrls
        : const [
            'https://picsum.photos/200/200?random=101',
            'https://picsum.photos/200/200?random=102',
            'https://picsum.photos/200/200?random=103',
            'https://picsum.photos/200/200?random=104',
          ];

    final displayCount = totalCount > 0 ? totalCount : items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MÍDIAS, LINKS E ARQUIVOS ($displayCount)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            GestureDetector(
              onTap: onViewAll ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Galeria de mídias da conversa'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
              child: Text(
                'Ver todas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = items[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: colorScheme.surfaceContainerHigh,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
