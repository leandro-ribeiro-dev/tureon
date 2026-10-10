import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/protocol/recipient.dart';

/// Debounced remote lookup, short username cache and stale-result rejection.
class ChatSearchController extends ChangeNotifier {
  ChatSearchController({
    required this.searchUsers,
    required this.searchGroups,
    String? initialQuery,
  }) : _searchQuery = initialQuery ?? '';
  final Future<List<Recipient>> Function(String)? Function() searchUsers;
  final Future<List<Recipient>> Function(String)? Function() searchGroups;
  static const _userSearchCacheLifetime = Duration(seconds: 30);
  static const _maxCachedUserSearches = 20;
  String _searchQuery = '';
  List<Recipient> _remoteResults = const [];
  String? _remoteError;
  bool _isSearchingRemote = false;
  Timer? _searchDebounce;
  int _searchGeneration = 0;
  final Map<String, ({DateTime cachedAt, List<Recipient> results})>
  _userSearchCache = {};
  bool _disposed = false;
  bool get isActive => !_disposed;
  String get query => _searchQuery;
  List<Recipient> get results => _remoteResults;
  String? get error => _remoteError;
  bool get isSearching => _isSearchingRemote;
  void _update(VoidCallback update) {
    if (_disposed) return;
    update();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchGeneration++;
    _searchDebounce?.cancel();
    _userSearchCache.clear();
    super.dispose();
  }

  void search(String value) {
    final query = value.trim().replaceFirst(RegExp(r'^@'), '');
    _searchDebounce?.cancel();
    final generation = ++_searchGeneration;

    _update(() {
      _searchQuery = value;
      _remoteResults = const [];
      _remoteError = null;
      _isSearchingRemote =
          query.length >= 2 &&
          (searchUsers() != null || searchGroups() != null);
    });

    if (query.length < 2) return;
    final findUsers = searchUsers();
    final findGroups = searchGroups();
    if (findUsers == null && findGroups == null) {
      _update(() {
        _remoteError = 'Conecte-se para pesquisar na rede.';
        _isSearchingRemote = false;
      });
      return;
    }

    final canSearchUsername = RegExp(r'^[a-zA-Z0-9_]{2,32}$').hasMatch(query);

    // Public groups and channels are never cached: their visibility can change
    // at any time. Username-only searches keep a short local cache.
    final cachedUsers = findGroups == null ? _userSearchCache[query] : null;
    if (cachedUsers != null &&
        DateTime.now().difference(cachedUsers.cachedAt) <
            _userSearchCacheLifetime) {
      _update(() {
        _remoteResults = cachedUsers.results;
        _isSearchingRemote = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final resultSets = await Future.wait<List<Recipient>>([
          if (findGroups != null) findGroups(query),
          if (findUsers != null && canSearchUsername) findUsers(query),
        ]);
        final uniqueResults = <String, Recipient>{};
        for (final resultSet in resultSets) {
          for (final recipient in resultSet) {
            uniqueResults.putIfAbsent(recipient.id, () => recipient);
          }
        }
        final results = uniqueResults.values.toList(growable: false);
        if (!isActive || generation != _searchGeneration) return;
        if (findGroups == null) {
          _userSearchCache[query] = (
            cachedAt: DateTime.now(),
            results: List<Recipient>.unmodifiable(results),
          );
          if (_userSearchCache.length > _maxCachedUserSearches) {
            final oldest = _userSearchCache.entries.reduce(
              (a, b) => a.value.cachedAt.isBefore(b.value.cachedAt) ? a : b,
            );
            _userSearchCache.remove(oldest.key);
          }
        }
        _update(() {
          _remoteResults = results;
          _isSearchingRemote = false;
        });
      } catch (error) {
        if (!isActive || generation != _searchGeneration) return;
        _update(() {
          _remoteError = 'Falha ao buscar resultados na rede: $error';
          _isSearchingRemote = false;
        });
      }
    });
  }
}
