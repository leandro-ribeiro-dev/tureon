import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/github_contributors_repository.dart';
import '../../domain/github_contributor.dart';

final githubContributorsRepositoryProvider =
    Provider<GitHubContributorsRepository>(
      (ref) => GitHubContributorsRepository(),
    );

final githubContributorsProvider = FutureProvider.autoDispose
    .family<List<GitHubContributor>, String>((ref, repository) {
      return ref
          .watch(githubContributorsRepositoryProvider)
          .listContributors(repository);
    });
