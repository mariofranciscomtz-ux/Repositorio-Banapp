import 'package:flutter/material.dart';
import '../../cinta_colores.dart';
import '../../data/supabase_client.dart';
import '../../embolse_year.dart';
import '../../models/finca.dart';
import '../../models/lote.dart';
import '../../widgets/app_logo.dart';

class _LoteAnual {
  final String nombre;
  final double hectareas;
  final List<int> semanas; // 52 valores, uno por semana del año de embolse
  _LoteAnual(this.nombre, this.hectareas, this.semanas);

  int get total => semanas.fold(0, (a, b) => a + b);
  double get racimosPorHa => hectareas > 0 ? total / hectareas : 0;
}

class ReporteAnualScreen extends StatelessWidget {
  final Finca finca;
  const ReporteAnualScreen({super.key, required this.finca});

  Future<(List<Lote>, List<Map<String, dynamic>>)> _cargarDatos(
      DateTime inicio, DateTime fin) async {
    final lotesData = await supabase
        .from('lotes')
        .select()
        .eq('finca_id', finca.id)
        .order('nombre');
    final idData = await supabase
        .from('identificaciones_racimos')
        .select()
        .eq('finca_id', finca.id)
        .gte('fecha', dateOnly(inicio))
        .lt('fecha', dateOnly(fin));
    return (lotesData.map(Lote.fromRow).toList(), idData);
  }

  @override
  Widget build(BuildContext context) {
    final anio = embolseYearFor(DateTime.now());
    final inicio = embolseYearStart(anio);
    final fin = embolseYearEnd(anio);
    final semanasHeaders = List.generate(52, (i) {
      final ini = inicio.add(Duration(days: i * 7));
      return (numero: isoWeekNumber(ini), color: colorCintaParaFecha(ini));
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Embolse año $anio · ${finca.nombre}',
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _cargarDatos(inicio, fin),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (lotesData, registros) = snapshot.data!;

          final lotes = lotesData.map((lote) {
            final semanas = List.filled(52, 0);
            for (final row in registros) {
              if (row['lote_id'] != lote.id) continue;
              final fechaStr = row['fecha'] as String?;
              final cantidad = row['cantidad_racimos'] as int?;
              if (fechaStr == null || cantidad == null) continue;
              final fecha = DateTime.parse(fechaStr);
              final idx = fecha.difference(inicio).inDays ~/ 7;
              if (idx >= 0 && idx < 52) {
                semanas[idx] += cantidad;
              }
            }
            return _LoteAnual(lote.nombre, lote.hectareas, semanas);
          }).toList()
            ..sort((a, b) => a.nombre.compareTo(b.nombre));

          if (lotes.isEmpty) {
            return const Center(child: Text('Esta finca no tiene lotes registrados'));
          }

          final totalesSemana = List.generate(
              52, (i) => lotes.fold<int>(0, (s, l) => s + l.semanas[i]));
          final totalHectareas = lotes.fold<double>(0, (s, l) => s + l.hectareas);
          final totalGeneral = totalesSemana.fold<int>(0, (a, b) => a + b);

          final scrollHorizontal = ScrollController();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Racimos embolsados por lote',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _TablaEmbolse(
                lotes: lotes,
                semanasHeaders: semanasHeaders,
                totalesSemana: totalesSemana,
                totalGeneral: totalGeneral,
                horizontalController: scrollHorizontal,
                mostrarPorHectarea: false,
              ),
              const SizedBox(height: 28),
              Text('Racimos por hectárea',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _TablaEmbolse(
                lotes: lotes,
                semanasHeaders: semanasHeaders,
                totalesSemana: totalesSemana,
                totalGeneral: totalGeneral,
                totalHectareas: totalHectareas,
                horizontalController: scrollHorizontal,
                mostrarPorHectarea: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TablaEmbolse extends StatelessWidget {
  final List<_LoteAnual> lotes;
  final List<({int numero, String color})> semanasHeaders;
  final List<int> totalesSemana;
  final int totalGeneral;
  final double totalHectareas;
  final ScrollController horizontalController;
  final bool mostrarPorHectarea;

  const _TablaEmbolse({
    required this.lotes,
    required this.semanasHeaders,
    required this.totalesSemana,
    required this.totalGeneral,
    this.totalHectareas = 0,
    required this.horizontalController,
    required this.mostrarPorHectarea,
  });

  static const _loteColWidth = 56.0;
  static const _weekColWidth = 54.0;
  static const _totalColWidth = 64.0;

  String _celda(int cantidad, double hectareas) {
    if (!mostrarPorHectarea) return cantidad == 0 ? '-' : '$cantidad';
    if (hectareas <= 0) return '-';
    final valor = cantidad / hectareas;
    return valor == 0 ? '-' : valor.toStringAsFixed(1);
  }

  Widget _cellBox(double width, Widget child) {
    return SizedBox(
      width: width,
      child: Align(alignment: Alignment.centerRight, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: horizontalController,
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        columns: [
          DataColumn(label: _cellBox(_loteColWidth, const Text('Lote'))),
          ...semanasHeaders.map((s) {
            final fondo = cintaColores[s.color] ?? Colors.grey;
            final texto =
                fondo.computeLuminance() > 0.5 ? Colors.black : Colors.white;
            return DataColumn(
              label: _cellBox(
                _weekColWidth,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: fondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 0.5),
                  ),
                  child: Text(
                    'S${s.numero}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: texto,
                    ),
                  ),
                ),
              ),
              numeric: true,
            );
          }),
          DataColumn(label: _cellBox(_totalColWidth, const Text('Total'))),
        ],
        rows: [
          ...lotes.map((l) => DataRow(cells: [
                DataCell(_cellBox(_loteColWidth, Text(l.nombre))),
                ...l.semanas.map((c) => DataCell(
                    _cellBox(_weekColWidth, Text(_celda(c, l.hectareas))))),
                DataCell(_cellBox(
                  _totalColWidth,
                  Text(
                    mostrarPorHectarea
                        ? l.racimosPorHa.toStringAsFixed(1)
                        : '${l.total}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
              ])),
          DataRow(
            color: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primaryContainer),
            cells: [
              DataCell(_cellBox(_loteColWidth,
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)))),
              ...totalesSemana.map((c) => DataCell(_cellBox(
                  _weekColWidth,
                  Text(
                    _celda(c, totalHectareas),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )))),
              DataCell(_cellBox(
                _totalColWidth,
                Text(
                  mostrarPorHectarea
                      ? (totalHectareas > 0
                          ? (totalGeneral / totalHectareas).toStringAsFixed(1)
                          : '-')
                      : '$totalGeneral',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
