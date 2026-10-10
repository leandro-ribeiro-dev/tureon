import 'package:sqlite3/sqlite3.dart';

/// Reuses compiled SQL in the synchronous message pipeline. Only statements
/// are cached: every call binds the current account and reads fresh rows.
class MessageStatementCache {
  MessageStatementCache(this.database);

  final Database database;
  final Map<String, PreparedStatement> _statements = {};

  PreparedStatement _statement(String sql) {
    final existing = _statements.remove(sql);
    if (existing != null) {
      _statements[sql] = existing;
      return existing;
    }
    if (_statements.length >= 32) {
      _statements.remove(_statements.keys.first)!.close();
    }
    return _statements[sql] = database.prepare(sql);
  }

  ResultSet select(String sql, List<Object?> parameters) =>
      _statement(sql).select(parameters);

  void execute(String sql, List<Object?> parameters) =>
      _statement(sql).execute(parameters);

  void close() {
    for (final statement in _statements.values) {
      statement.close();
    }
    _statements.clear();
  }
}
