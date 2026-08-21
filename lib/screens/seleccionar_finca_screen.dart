import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/powersync.dart';
import '../data/sesion.dart';
import '../models/finca.dart';
import '../saludo.dart';

class SeleccionarFincaScreen extends StatelessWidget {
  const SeleccionarFincaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saludo = saludoSegunHora();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(saludo.icono, size: 32, color: colorScheme.primary),
                        const SizedBox(height: 10),
                        Text(
                          saludo.texto,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¿En qué finca vas a trabajar hoy?',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
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
            ),
            Expanded(
              child: StreamBuilder(
                stream: db.watch('SELECT * FROM fincas ORDER BY nombre'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error cargando fincas: ${snapshot.error}'));
                  }
                  final fincas =
                      snapshot.data?.map(Finca.fromRow).toList() ?? const <Finca>[];
                  if (fincas.isEmpty) {
                    return const Center(child: Text('No hay fincas registradas'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    itemCount: fincas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final f = fincas[index];
                      return Material(
                        color: colorScheme.surface,
                        elevation: 1,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => fincaSeleccionada.value = f,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: colorScheme.secondaryContainer,
                                  child: Icon(Icons.agriculture,
                                      color: colorScheme.onSecondaryContainer),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    f.nombre,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: colorScheme.outline),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
