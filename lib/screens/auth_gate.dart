import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/sesion.dart';
import '../models/finca.dart';
import '../models/usuario.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'seleccionar_finca_screen.dart';
import 'seleccionar_usuario_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) return const LoginScreen();

        return ValueListenableBuilder<Usuario?>(
          valueListenable: usuarioActivo,
          builder: (context, usuario, _) {
            if (usuario == null) return const SeleccionarUsuarioScreen();

            return ValueListenableBuilder<Finca?>(
              valueListenable: fincaSeleccionada,
              builder: (context, finca, _) {
                return finca == null
                    ? const SeleccionarFincaScreen()
                    : const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}
