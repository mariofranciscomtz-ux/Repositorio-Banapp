import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/sesion.dart';
import 'racimos/racimos_screen.dart';
import 'cosecha/cosecha_screen.dart';
import 'cajas/cajas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modulos = [
      (
        titulo: 'Racimos identificados',
        subtitulo: 'Registro en edad 0 (cinta semanal)',
        icono: Icons.local_florist,
        pantalla: const RacimosScreen(),
      ),
      (
        titulo: 'Cosecha',
        subtitulo: 'Corte de racimos y datos de calidad',
        icono: Icons.agriculture,
        pantalla: const CosechaScreen(),
      ),
      (
        titulo: 'Cajas procesadas',
        subtitulo: 'Conteo por tipo de caja y peso',
        icono: Icons.inventory_2,
        pantalla: const CajasScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(fincaSeleccionada.value?.nombre ?? 'Banapp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar finca',
            onPressed: () => fincaSeleccionada.value = null,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              fincaSeleccionada.value = null;
              Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: modulos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final m = modulos[index];
          return Card(
            child: ListTile(
              leading: Icon(m.icono, size: 32),
              title: Text(m.titulo),
              subtitle: Text(m.subtitulo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => m.pantalla),
              ),
            ),
          );
        },
      ),
    );
  }
}
