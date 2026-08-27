import 'package:flutter/material.dart';
import '../../data/supabase_client.dart';
import '../../embolse_year.dart';
import '../../models/finca.dart';
import '../../models/lote.dart';

const _edadesCosecha = [8, 9, 10, 11, 12];

class ResumenSemanalScreen extends StatefulWidget {
  final Finca finca;
  const ResumenSemanalScreen({super.key, required this.finca});

  @override
  State<ResumenSemanalScreen> createState() => _ResumenSemanalScreenState();
}

class _ResumenSemanalScreenState extends State<ResumenSemanalScreen> {
  late final int _anio;
  late final DateTime _inicioAnio;
  late final List<({int numero, DateTime inicio, DateTime fin})> _semanas;
  late int _semanaSeleccionada;

  @override
  void initState() {
    super.initState();
    _anio = embolseYearFor(DateTime.now());
    _inicioAnio = embolseYearStart(_anio);
    _semanas = List.generate(52, (i) {
      final ini = _inicioAnio.add(Duration(days: i * 7));
      final fin = ini.add(const Duration(days: 7));
      return (numero: isoWeekNumber(ini), inicio: ini, fin: fin);
    });
    final idxHoy = DateTime.now().difference(_inicioAnio).inDays ~/ 7;
    _semanaSeleccionada = idxHoy.clamp(0, 51);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  Future<(List<Lote>, List<Map<String, dynamic>>)> _cargarDatos(
      DateTime inicio, DateTime fin) async {
    final lotesData = await supabase
        .from('lotes')
        .select()
        .eq('finca_id', widget.finca.id);
    final viajesData = await supabase
        .from('cosecha_viajes')
        .select()
        .eq('finca_id', widget.finca.id)
        .gte('fecha', dateOnly(inicio))
        .lt('fecha', dateOnly(fin));
    return (lotesData.map(Lote.fromRow).toList(), viajesData);
  }

  @override
  Widget build(BuildContext context) {
    final semana = _semanas[_semanaSeleccionada];
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen semanal · ${widget.finca.nombre}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Semana',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _semanaSeleccionada,
                  isExpanded: true,
                  items: List.generate(52, (i) {
                    final s = _semanas[i];
                    return DropdownMenuItem(
                      value: i,
                      child: Text(
                          'Semana ${s.numero} · ${_fmt(s.inicio)} – ${_fmt(s.fin.subtract(const Duration(days: 1)))}'),
                    );
                  }),
                  onChanged: (i) => setState(() => _semanaSeleccionada = i!),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _cargarDatos(semana.inicio, semana.fin),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error cargando datos: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final (lotes, filas) = snapshot.data!;
                if (filas.isEmpty) {
                  return const Center(
                      child: Text('Sin viajes registrados en esta semana'));
                }
                final lotesPorId = {for (final l in lotes) l.id: l};

                final porLote = <String, Map<int, int>>{};
                final recusadosPorLote = <String, int>{};
                final calibSumaPorEdad = {for (final e in _edadesCosecha) e: 0.0};
                final calibPesoPorEdad = {for (final e in _edadesCosecha) e: 0};
                for (final f in filas) {
                  final lote =
                      lotesPorId[f['lote_id']]?.nombre ?? '(lote eliminado)';
                  final mapa = porLote.putIfAbsent(
                      lote, () => {for (final e in _edadesCosecha) e: 0});
                  for (final e in _edadesCosecha) {
                    final cantidad = f['racimos_edad_$e'] as int;
                    mapa[e] = mapa[e]! + cantidad;
                    final calib = (f['calibracion_edad_$e'] as num?)?.toDouble();
                    if (calib != null && cantidad > 0) {
                      calibSumaPorEdad[e] = calibSumaPorEdad[e]! + calib * cantidad;
                      calibPesoPorEdad[e] = calibPesoPorEdad[e]! + cantidad;
                    }
                  }
                  recusadosPorLote[lote] = (recusadosPorLote[lote] ?? 0) +
                      (f['racimos_recusados'] as int);
                }
                final lotesOrdenados = porLote.keys.toList()..sort();

                final totalPorEdad = {
                  for (final e in _edadesCosecha)
                    e: porLote.values.fold<int>(0, (s, m) => s + m[e]!),
                };
                final calibPromPorEdad = {
                  for (final e in _edadesCosecha)
                    e: calibPesoPorEdad[e]! > 0
                        ? calibSumaPorEdad[e]! / calibPesoPorEdad[e]!
                        : null,
                };
                final totalRecusados =
                    recusadosPorLote.values.fold<int>(0, (a, b) => a + b);
                final totalGeneral =
                    totalPorEdad.values.fold<int>(0, (a, b) => a + b) +
                        totalRecusados;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          const DataColumn(label: Text('Lote')),
                          ..._edadesCosecha.map((e) => DataColumn(
                              label: Text('$e sem'), numeric: true)),
                          const DataColumn(label: Text('Recus.'), numeric: true),
                          const DataColumn(label: Text('Total'), numeric: true),
                        ],
                        rows: [
                          ...lotesOrdenados.map((lote) {
                            final mapa = porLote[lote]!;
                            final recus = recusadosPorLote[lote] ?? 0;
                            final total =
                                mapa.values.fold(0, (a, b) => a + b) + recus;
                            return DataRow(cells: [
                              DataCell(Text(lote)),
                              ..._edadesCosecha
                                  .map((e) => DataCell(Text('${mapa[e]}'))),
                              DataCell(Text('$recus')),
                              DataCell(Text('$total')),
                            ]);
                          }),
                          DataRow(
                            color: WidgetStateProperty.all(Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest),
                            cells: [
                              const DataCell(Text('Total finca',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                              ..._edadesCosecha.map((e) => DataCell(Text(
                                  '${totalPorEdad[e]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)))),
                              DataCell(Text('$totalRecusados',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                              DataCell(Text('$totalGeneral',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Distribución de racimos cosechados por edad (finca)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    ..._edadesCosecha.map((e) {
                      final cantidad = totalPorEdad[e]!;
                      final pct =
                          totalGeneral > 0 ? cantidad / totalGeneral * 100 : 0.0;
                      final calib = calibPromPorEdad[e];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 78, child: Text('$e semanas')),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  minHeight: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: Text(
                                  '$cantidad · ${pct.toStringAsFixed(1)}%',
                                  textAlign: TextAlign.right),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                calib != null
                                    ? 'Calib. ${calib.toStringAsFixed(1)}'
                                    : 'Calib. —',
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (totalRecusados > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Recusados: $totalRecusados (${(totalRecusados / totalGeneral * 100).toStringAsFixed(1)}% del total de la semana)',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
