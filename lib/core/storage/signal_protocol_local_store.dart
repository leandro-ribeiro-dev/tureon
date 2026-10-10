import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

class SignalProtocolLocalStore {
  SignalProtocolLocalStore({
    required this.database,
    required this.accountId,
    required this.onWrite,
  });

  final Database database;
  final String Function() accountId;
  final void Function() onWrite;

  Uint8List? read(String recordKey) {
    final rows = database.select(
      'SELECT encrypted_record FROM account_signal_protocol_records WHERE account_id = ? AND record_key = ?',
      [accountId(), recordKey],
    );
    if (rows.isEmpty) return null;
    return Uint8List.fromList(rows.first['encrypted_record'] as List<int>);
  }

  void write(String recordKey, Uint8List encryptedRecord) {
    database.execute(
      '''
      INSERT INTO account_signal_protocol_records(
        account_id, record_key, encrypted_record
      ) VALUES (?, ?, ?)
      ON CONFLICT(account_id, record_key)
      DO UPDATE SET encrypted_record = excluded.encrypted_record;
      ''',
      [accountId(), recordKey, encryptedRecord],
    );
    onWrite();
  }

  void delete(String recordKey) {
    database.execute(
      'DELETE FROM account_signal_protocol_records WHERE account_id = ? AND record_key = ?',
      [accountId(), recordKey],
    );
    onWrite();
  }

  List<String> listKeys(String prefix) => database
      .select(
        'SELECT record_key FROM account_signal_protocol_records WHERE account_id = ? AND record_key LIKE ? ORDER BY record_key',
        [accountId(), '$prefix%'],
      )
      .map((row) => row['record_key'] as String)
      .toList(growable: false);
}
