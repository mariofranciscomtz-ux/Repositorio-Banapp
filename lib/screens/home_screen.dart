import 'package:flutter/material.dart';
import '../data/clima_service.dart';
import '../data/sesion.dart';
import 'racimos/racimos_screen.dart';
import 'cosecha/cosecha_screen.dart';
import 'cajas/cajas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<ClimaActual>? _climaFuture;

  @override
  void initState() {
    super.initState();
    final finca = fincaSeleccionada.value;
    if (finca?.latitud != null && finca?.longitud != null) {
      _climaFuture = ClimaService.obtenerClimaActual(
        latitud: finca!.latitud!,
        longitud: finca.longitud!,
      );
    }
  }

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
            icon: const Icon(Icons.person_outline),
            tooltip: 'Cambiar usuario (${usuarioActivo.value?.nombre ?? ""})',
            onPressed: () => usuarioActivo.value = null,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar finca',
            onPressed: () => fincaSeleccionada.value = null,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_climaFuture != null) _ClimaCard(future: _climaFuture!),
          if (_climaFuture != null) const SizedBox(height: 8),
          ...modulos.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: Icon(m.icono, size: 32),
                    title: Text(m.titulo),
                    subtitle: Text(m.subtitulo),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => m.pantalla),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _ClimaCard extends StatelessWidget {
  const _ClimaCard({required this.future});

  final Future<ClimaActual> future;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<ClimaActual>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Consultando el clima…'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se pudo obtener el clima'),
            ),
          );
        }

        final clima = snapshot.data!;
        return Card(
          color: colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(clima.icono, size: 36, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${clima.temperaturaC.round()}°C · ${clima.descripcion}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sensación ${clima.sensacionTermicaC.round()}°C · '
                        'Humedad ${clima.humedadPct}% · '
                        'Lluvia ${clima.precipitacionMm.toStringAsFixed(1)} mm',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
