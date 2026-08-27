import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/sesion.dart';
import '../models/finca.dart';
import '../models/usuario.dart';
import 'home_screen.dart';
import 'seleccionar_finca_screen.dart';
import 'seleccionar_usuario_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _reintentar() =>
      Supabase.instance.client.auth.signInAnonymously();

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
        if (session == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('No se pudo conectar con el servidor'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reintentar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
