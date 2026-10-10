import 'package:flutter/material.dart';

import '../../../../core/design_system/app_bottom_sheet.dart';
import '../../domain/support_models.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final searchController = TextEditingController();
  String selectedCategory = 'Todos';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<SupportArticle> get filteredArticles {
    final query = searchController.text.trim().toLowerCase();
    return supportArticles.where((article) {
      final categoryMatches =
          selectedCategory == 'Todos' || article.category == selectedCategory;
      final textMatches =
          query.isEmpty ||
          '${article.title} ${article.summary} ${article.body}'
              .toLowerCase()
              .contains(query);
      return categoryMatches && textMatches;
    }).toList();
  }

  void showContactOptions() {
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheetContainer(
        title: 'Suporte Tureon',
        subtitle: 'Atendimento disponível pelo canal oficial',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Conversar com a equipe',
              onTap: () => Navigator.pop(sheetContext),
            ),
            AppBottomSheetTile(
              icon: Icons.bug_report_outlined,
              title: 'Reportar um problema',
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      'Todos',
      ...supportArticles.map((item) => item.category).toSet(),
    ];
    final articles = filteredArticles;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda e suporte')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como podemos ajudar?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Encontre respostas rápidas sobre sua conta, mensagens e bots.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar na central de ajuda',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear_rounded),
                            ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final category = categories[index];
                        return ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (_) =>
                              setState(() => selectedCategory = category),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (articles.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final article = articles[index];
                  return Column(
                    children: [
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        leading: Icon(
                          article.popular
                              ? Icons.star_rounded
                              : Icons.article_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(
                          article.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(article.summary),
                        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              article.body,
                              style: const TextStyle(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        height: 1,
                      ),
                    ],
                  );
                }, childCount: articles.length),
              ),
            )
          else
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Nenhum artigo encontrado')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showContactOptions,
        icon: const Icon(Icons.support_agent_rounded),
        label: const Text('Falar com suporte'),
      ),
    );
  }
}
