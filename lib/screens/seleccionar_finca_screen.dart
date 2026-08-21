import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/powersync.dart';
import '../data/sesion.dart';
import '../models/finca.dart';
import '../saludo.dart';

class SeleccionarFincaScreen extends StatefulWidget {
  const SeleccionarFincaScreen({super.key});

  @override
  State<SeleccionarFincaScreen> createState() =>
      _SeleccionarFincaScreenState();
}

class _SeleccionarFincaScreenState extends State<SeleccionarFincaScreen> {
  String? _seleccionId;

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
                stream: db.watch('SELECT * FROM fincas ORDER BY orden, nombre'),
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

                  final seleccionValida =
                      fincas.any((f) => f.id == _seleccionId);
                  final idActual = seleccionValida ? _seleccionId : null;
                  final fincaActual = seleccionValida
                      ? fincas.firstWhere((f) => f.id == _seleccionId)
                      : null;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Finca',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: idActual,
                          decoration: InputDecoration(
                            hintText: 'Selecciona una finca',
                            prefixIcon: const Icon(Icons.agriculture),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: fincas
                              .map((f) => DropdownMenuItem(
                                    value: f.id,
                                    child: Text(f.nombre),
                                  ))
                              .toList(),
                          onChanged: (id) => setState(() => _seleccionId = id),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: fincaActual == null
                              ? null
                              : () => fincaSeleccionada.value = fincaActual,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Continuar'),
                        ),
                      ],
                    ),
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
