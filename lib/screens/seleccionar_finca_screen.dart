import 'package:flutter/material.dart';
import '../data/supabase_client.dart';
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
    final usuario = usuarioActivo.value!;

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
                    icon: const Icon(Icons.person_outline),
                    tooltip: 'Cambiar usuario (${usuario.nombre})',
                    onPressed: () => usuarioActivo.value = null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: supabase.from('fincas').stream(primaryKey: ['id']),
                builder: (context, fincasSnapshot) {
                  if (fincasSnapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error cargando fincas: ${fincasSnapshot.error}'));
                  }
                  final todasFincas = (fincasSnapshot.data ?? const [])
                      .map(Finca.fromRow)
                      .toList()
                    ..sort((a, b) {
                      final ordenA = a.orden ?? 1 << 30;
                      final ordenB = b.orden ?? 1 << 30;
                      final cmp = ordenA.compareTo(ordenB);
                      return cmp != 0 ? cmp : a.nombre.compareTo(b.nombre);
                    });

                  if (usuario.esAdmin) {
                    return _SelectorFincas(
                      fincas: todasFincas,
                      seleccionId: _seleccionId,
                      onSeleccion: (id) => setState(() => _seleccionId = id),
                    );
                  }

                  return StreamBuilder(
                    stream: supabase
                        .from('usuario_fincas')
                        .stream(primaryKey: ['usuario_id', 'finca_id']).eq(
                            'usuario_id', usuario.id),
                    builder: (context, permisosSnapshot) {
                      if (permisosSnapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error cargando permisos: ${permisosSnapshot.error}'));
                      }
                      final idsPermitidos = (permisosSnapshot.data ?? const [])
                          .map((r) => r['finca_id'] as String)
                          .toSet();
                      final fincasPermitidas = todasFincas
                          .where((f) => idsPermitidos.contains(f.id))
                          .toList();
                      return _SelectorFincas(
                        fincas: fincasPermitidas,
                        seleccionId: _seleccionId,
                        onSeleccion: (id) => setState(() => _seleccionId = id),
                        sinPermisosMensaje:
                            'No tienes fincas asignadas todavía. Pide a un administrador que te dé acceso.',
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

class _SelectorFincas extends StatelessWidget {
  final List<Finca> fincas;
  final String? seleccionId;
  final ValueChanged<String?> onSeleccion;
  final String sinPermisosMensaje;

  const _SelectorFincas({
    required this.fincas,
    required this.seleccionId,
    required this.onSeleccion,
    this.sinPermisosMensaje = 'No hay fincas registradas',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (fincas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(sinPermisosMensaje, textAlign: TextAlign.center),
        ),
      );
    }

    final seleccionValida = fincas.any((f) => f.id == seleccionId);
    final idActual = seleccionValida ? seleccionId : null;
    final fincaActual =
        seleccionValida ? fincas.firstWhere((f) => f.id == seleccionId) : null;

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
            onChanged: onSeleccion,
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
  }
}
