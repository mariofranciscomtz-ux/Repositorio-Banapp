import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_config.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  if (supabase.auth.currentSession == null) {
    // No hay login visible de correo/contraseña: el dispositivo se
    // autentica solo (sesión anónima) para poder leer/escribir en
    // Supabase; quién es cada trabajador se identifica luego con
    // usuario + PIN. Si falla (p. ej. sin conexión), no debe tumbar
    // el arranque de la app: AuthGate ofrece un botón de reintentar.
    try {
      await supabase.auth.signInAnonymously();
    } catch (_) {
      // AuthGate se encarga de reintentar.
    }
  }
}
