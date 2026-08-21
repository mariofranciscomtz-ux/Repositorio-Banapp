import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';

/// Postgres error codes we cannot recover from by retrying (e.g. constraint
/// violations or RLS rejections) — the offending change is discarded instead
/// of blocking the whole upload queue forever.
final fatalResponseCodes = [
  RegExp(r'^22...$'), // Data exception
  RegExp(r'^23...$'), // Integrity constraint violation
  RegExp(r'^42501$'), // Insufficient privilege (RLS)
];

class SupabaseConnector extends PowerSyncBackendConnector {
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    return PowerSyncCredentials(
      endpoint: AppConfig.powersyncUrl,
      token: session.accessToken,
      userId: session.user.id,
    );
  }

  @override
  void invalidateCredentials() {
    unawaited(() async {
      try {
        await Supabase.instance.client.auth
            .refreshSession()
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }());
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    final rest = Supabase.instance.client.rest;
    CrudEntry? lastOp;
    try {
      for (final op in transaction.crud) {
        lastOp = op;
        final table = rest.from(op.table);
        switch (op.op) {
          case UpdateType.put:
            final data = Map<String, dynamic>.of(op.opData!);
            data['id'] = op.id;
            await table.upsert(data);
          case UpdateType.patch:
            await table.update(op.opData!).eq('id', op.id);
          case UpdateType.delete:
            await table.delete().eq('id', op.id);
        }
      }
      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null && fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {
        debugPrint('Error subiendo cambio, se descarta: $lastOp ($e)');
        await transaction.complete();
      } else {
        rethrow;
      }
    }
  }
}
