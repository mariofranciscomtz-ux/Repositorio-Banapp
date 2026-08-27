import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';
import '../models/schema.dart';
import 'supabase_connector.dart';

late final PowerSyncDatabase db;

bool isLoggedIn() {
  return Supabase.instance.client.auth.currentSession?.accessToken != null;
}

String? currentUserId() {
  return Supabase.instance.client.auth.currentSession?.user.id;
}

Future<String> _databasePath() async {
  const dbFilename = 'banapp.db';
  if (kIsWeb) return dbFilename;
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, dbFilename);
}

Future<void> openDatabase() async {
  db = PowerSyncDatabase(schema: schema, path: await _databasePath());
  await db.initialize();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  if (!isLoggedIn()) {
    // No hay login visible de correo/contraseña: el dispositivo se
    // autentica solo (sesión anónima de Supabase) para poder sincronizar;
    // quién es cada trabajador se identifica luego con usuario + PIN.
    await Supabase.instance.client.auth.signInAnonymously();
  }

  if (isLoggedIn()) {
    db.connect(connector: SupabaseConnector());
  }

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    switch (data.event) {
      case AuthChangeEvent.signedIn:
        db.connect(connector: SupabaseConnector());
      case AuthChangeEvent.signedOut:
        await db.disconnect();
      default:
        break;
    }
  });
}
