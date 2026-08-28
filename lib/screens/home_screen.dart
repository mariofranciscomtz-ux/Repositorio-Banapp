import 'package:flutter/material.dart';
import '../data/clima_service.dart';
import '../data/sesion.dart';
import '../saludo.dart';
import '../widgets/app_logo.dart';
import 'configuracion_screen.dart';
import 'racimos/racimos_screen.dart';
import 'cosecha/cosecha_screen.dart';
import 'cajas/cajas_screen.dart';

class _Modulo {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final Widget pantalla;
  const _Modulo({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.pantalla,
  });
}

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
    final colorScheme = Theme.of(context).colorScheme;
    final saludo = saludoSegunHora();

    final modulos = [
      _Modulo(
        titulo: 'Racimos identificados',
        subtitulo: 'Registro en edad 0 (cinta semanal)',
        icono: Icons.local_florist,
        color: colorScheme.primary,
        pantalla: const RacimosScreen(),
      ),
      _Modulo(
        titulo: 'Cosecha',
        subtitulo: 'Corte de racimos y datos de calidad',
        icono: Icons.agriculture,
        color: const Color(0xFFEF6C00),
        pantalla: const CosechaScreen(),
      ),
      _Modulo(
        titulo: 'Cajas procesadas',
        subtitulo: 'Conteo por tipo de caja y peso',
        icono: Icons.inventory_2,
        color: const Color(0xFF1565C0),
        pantalla: const CajasScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    Color.lerp(colorScheme.primary, Colors.black, 0.25)!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(saludo.icono,
                                size: 22, color: Colors.white.withValues(alpha: 0.9)),
                            const SizedBox(width: 8),
                            Text(
                              saludo.texto,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fincaSeleccionada.value?.nombre ?? 'Banapp',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (usuarioActivo.value != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              usuarioActivo.value!.nombre,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (usuarioActivo.value?.esAdmin ?? false)
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.white),
                      tooltip: 'Configuración',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ConfiguracionScreen()),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    tooltip: 'Cambiar usuario (${usuarioActivo.value?.nombre ?? ""})',
                    onPressed: () => usuarioActivo.value = null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    tooltip: 'Cambiar finca',
                    onPressed: () => fincaSeleccionada.value = null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  if (_climaFuture != null) _ClimaCard(future: _climaFuture!),
                  if (_climaFuture != null) const SizedBox(height: 14),
                  ...modulos.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => m.pantalla),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: m.color.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(m.icono, size: 28, color: m.color),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.titulo,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          m.subtitulo,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: colorScheme.outline),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
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
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.tertiaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(clima.icono,
                          size: 30, color: colorScheme.onSecondaryContainer),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${clima.temperaturaC.round()}°C · ${clima.descripcion}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
                              color: colorScheme.onSecondaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (clima.proximosDias.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      color: colorScheme.onSecondaryContainer.withValues(alpha: 0.2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: clima.proximosDias
                        .map((d) => _DiaPronostico(dia: d))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

const _diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

class _DiaPronostico extends StatelessWidget {
  const _DiaPronostico({required this.dia});

  final PronosticoDia dia;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onColor = colorScheme.onSecondaryContainer;

    return Column(
      children: [
        Text(
          _diasSemana[dia.fecha.weekday - 1],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onColor.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 4),
        Icon(dia.icono, size: 22, color: onColor),
        const SizedBox(height: 4),
        Text(
          '${dia.tempMaxC.round()}° / ${dia.tempMinC.round()}°',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onColor,
          ),
        ),
        if (dia.precipitacionMm > 0)
          Text(
            '${dia.precipitacionMm.toStringAsFixed(0)} mm',
            style: TextStyle(
              fontSize: 10,
              color: onColor.withValues(alpha: 0.75),
            ),
          ),
      ],
    );
  }
}
