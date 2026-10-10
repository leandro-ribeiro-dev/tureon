import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tureon/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/github_contributor.dart';
import '../providers/about_providers.dart';

class AboutView extends ConsumerWidget {
  const AboutView({super.key});

  static const _repository = 'leandro-ribeiro-dev/tureon';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contributors = ref.watch(githubContributorsProvider(_repository));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: _AboutHeader(
                title: l10n.appTitle,
                subtitle: l10n.aboutDescription,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _ContributorSection(
                    state: contributors,
                    title: l10n.aboutContributorsTitle,
                    loadingLabel: l10n.aboutContributorsLoading,
                    emptyLabel: l10n.aboutContributorsEmpty,
                    errorLabel: l10n.aboutContributorsError,
                    retryLabel: l10n.aboutRetry,
                    onRetry: () =>
                        ref.invalidate(githubContributorsProvider(_repository)),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: _CommunitySection(
                title: l10n.aboutCommunityTitle,
                contributeLabel: l10n.aboutContributeLabel,
                githubLabel: l10n.aboutGithubLabel,
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/$_repository'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(
                  '© ${DateTime.now().year} Tureon',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.forum_rounded,
            color: theme.colorScheme.onPrimaryContainer,
            size: 36,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContributorSection extends StatelessWidget {
  const _ContributorSection({
    required this.state,
    required this.title,
    required this.loadingLabel,
    required this.emptyLabel,
    required this.errorLabel,
    required this.retryLabel,
    required this.onRetry,
  });

  final AsyncValue<List<GitHubContributor>> state;
  final String title;
  final String loadingLabel;
  final String emptyLabel;
  final String errorLabel;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        state.when(
          data: (contributors) => contributors.isEmpty
              ? Text(emptyLabel)
              : _ContributorWrap(contributors: contributors),
          error: (error, stackTrace) => Row(
            children: [
              Expanded(child: Text(errorLabel)),
              TextButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ),
          loading: () => Semantics(
            label: loadingLabel,
            child: const _ContributorPlaceholders(),
          ),
        ),
      ],
    );
  }
}

class _ContributorWrap extends StatelessWidget {
  const _ContributorWrap({required this.contributors});

  final List<GitHubContributor> contributors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final contributor in contributors)
          Tooltip(
            message: contributor.login,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => launchUrl(
                Uri.parse(contributor.profileUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  contributor.avatarUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    radius: 16,
                    child: Text(
                      contributor.login.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ContributorPlaceholders extends StatelessWidget {
  const _ContributorPlaceholders();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        36,
        (_) => DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox(width: 32, height: 32),
        ),
      ),
    );
  }
}

class _CommunitySection extends StatelessWidget {
  const _CommunitySection({
    required this.title,
    required this.contributeLabel,
    required this.githubLabel,
    required this.onTap,
  });

  final String title;
  final String contributeLabel;
  final String githubLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(contributeLabel, overflow: TextOverflow.ellipsis),
          subtitle: InkWell(
            onTap: onTap,
            child: Text(
              githubLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
