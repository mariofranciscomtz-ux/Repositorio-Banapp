import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_config.dart';

SupabaseClient get supabase => Supabase.instance.client;

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  final session = supabase.auth.currentSession;

  if (session == null) {
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
  } else if (session.isExpired) {
    // La sesión guardada (p. ej. de una pestaña que estuvo mucho rato
    // inactiva) ya expiró. Si no se renueva aquí, Realtime intenta
    // suscribirse con el token vencido antes de que la renovación
    // automática en segundo plano termine, y las pantallas fallan con
    // "Token has expired". Se renueva de una vez, antes de que
    // cualquier pantalla intente abrir una suscripción.
    try {
      await supabase.auth.refreshSession();
    } catch (_) {
      try {
        await supabase.auth.signInAnonymously();
      } catch (_) {
        // AuthGate se encarga de reintentar.
      }
    }
  }
}
