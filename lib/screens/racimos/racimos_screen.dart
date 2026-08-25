import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:powersync/powersync.dart' hide Column;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cinta_colores.dart';
import '../../data/powersync.dart';
import '../../data/sesion.dart' as sesion;
import '../../embolse_year.dart';
import '../../models/lote.dart';
import 'reporte_anual_screen.dart';

class _FilaLote {
  final String loteNombre;
  final double hectareas;
  final int primera;
  final int segunda;
  _FilaLote({
    required this.loteNombre,
    required this.hectareas,
    required this.primera,
    required this.segunda,
  });

  int get total => primera + segunda;
  double get racimosPorHa => hectareas > 0 ? total / hectareas : 0;

  factory _FilaLote.fromRow(dynamic row) => _FilaLote(
        loteNombre: row['lote_nombre'] as String,
        hectareas: (row['hectareas'] as num).toDouble(),
        primera: row['primera'] as int,
        segunda: row['segunda'] as int,
      );
}

(DateTime, DateTime) _rangoSemanaActual() {
  final ahora = DateTime.now();
  final inicio = DateTime(ahora.year, ahora.month, ahora.day)
      .subtract(Duration(days: ahora.weekday - 1));
  return (inicio, inicio.add(const Duration(days: 7)));
}

class RacimosScreen extends StatefulWidget {
  const RacimosScreen({super.key});

  @override
  State<RacimosScreen> createState() => _RacimosScreenState();
}

class _RacimosScreenState extends State<RacimosScreen> {
  // Se recuerda entre visitas, ya que un trabajador suele quedarse
  // identificando racimos en el mismo lote por un buen rato.
  static String? _ultimoLoteId;

  final _captureKey = GlobalKey();
  bool _compartiendo = false;

  Future<void> _abrirFormulario() async {
    final finca = sesion.fincaSeleccionada.value!;

    final lotes = (await db.getAll(
      'SELECT * FROM lotes WHERE finca_id = ? ORDER BY nombre',
      [finca.id],
    ))
        .map(Lote.fromRow)
        .toList();

    if (lotes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${finca.nombre} no tiene lotes registrados'),
      ));
      return;
    }
    Lote loteSeleccionado =
        lotes.firstWhere((l) => l.id == _ultimoLoteId, orElse: () => lotes.first);

    final ahora = DateTime.now();
    final colorSemana = colorCintaParaFecha(ahora);
    String? vueltaSeleccionada;
    final cantidadController = TextEditingController();

    if (!mounted) return;
    final creado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Identificar racimos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Lote>(
                  initialValue: loteSeleccionado,
                  decoration: const InputDecoration(labelText: 'Lote'),
                  items: lotes
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l.nombre)))
                      .toList(),
                  onChanged: (l) => setDialogState(() => loteSeleccionado = l!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Cantidad de racimos identificados'),
                ),
                const SizedBox(height: 16),
                const Text('Vuelta'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Primera (lun-mié)'),
                      selected: vueltaSeleccionada == 'primera',
                      onSelected: (_) =>
                          setDialogState(() => vueltaSeleccionada = 'primera'),
                    ),
                    ChoiceChip(
                      label: const Text('Segunda (jue-sáb)'),
                      selected: vueltaSeleccionada == 'segunda',
                      onSelected: (_) =>
                          setDialogState(() => vueltaSeleccionada = 'segunda'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Color de cinta (semana actual)'),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cintaColores[colorSemana]!,
                          border: Border.all(color: Colors.grey.shade500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        colorSemana,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: vueltaSeleccionada == null
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    final cantidad = int.tryParse(cantidadController.text);
    if (creado == true && cantidad != null) {
      _ultimoLoteId = loteSeleccionado.id;
      await db.execute(
        'INSERT INTO identificaciones_racimos '
        '(id, lote_id, fecha, color_cinta, vuelta, cantidad_racimos, identificado_por) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          uuid.v4(),
          loteSeleccionado.id,
          dateOnly(DateTime.now()),
          colorSemana,
          vueltaSeleccionada,
          cantidad,
          Supabase.instance.client.auth.currentUser?.id,
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Identificación guardada'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _compartirTabla(String fincaNombre) async {
    setState(() => _compartiendo = true);
    try {
      final boundary = _captureKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: 'racimos_$fincaNombre.png',
              mimeType: 'image/png',
            ),
          ],
          text: 'Racimos identificados - $fincaNombre',
        ),
      );
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finca = sesion.fincaSeleccionada.value!;
    final (inicioSemana, finSemana) = _rangoSemanaActual();

    return Scaffold(
      appBar: AppBar(
        title: Text('Racimos identificados · ${finca.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            tooltip: 'Reporte anual de embolse',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReporteAnualScreen(finca: finca),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: db.watch(
          'SELECT l.id as lote_id, l.nombre as lote_nombre, l.hectareas, '
          "  SUM(CASE WHEN ir.vuelta = 'primera' THEN ir.cantidad_racimos ELSE 0 END) as primera, "
          "  SUM(CASE WHEN ir.vuelta = 'segunda' THEN ir.cantidad_racimos ELSE 0 END) as segunda "
          'FROM lotes l '
          'LEFT JOIN identificaciones_racimos ir ON ir.lote_id = l.id '
          '  AND ir.fecha >= ? AND ir.fecha < ? '
          'WHERE l.finca_id = ? '
          'GROUP BY l.id, l.nombre, l.hectareas '
          'ORDER BY l.nombre',
          parameters: [
            dateOnly(inicioSemana),
            dateOnly(finSemana),
            finca.id,
          ],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final filas = snapshot.data!.map(_FilaLote.fromRow).toList();
          if (filas.isEmpty) {
            return const Center(child: Text('Esta finca no tiene lotes registrados'));
          }

          final totalPrimera = filas.fold<int>(0, (s, f) => s + f.primera);
          final totalSegunda = filas.fold<int>(0, (s, f) => s + f.segunda);
          final totalGeneral = totalPrimera + totalSegunda;
          final totalHectareas = filas.fold<double>(0, (s, f) => s + f.hectareas);
          final totalRacimosPorHa =
              totalHectareas > 0 ? totalGeneral / totalHectareas : 0;
          final lotesFaltantes = filas.where((f) => f.total == 0).length;
          final completo = lotesFaltantes == 0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${finca.nombre} · Semana actual',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Lote')),
                                DataColumn(label: Text('1a vuelta'), numeric: true),
                                DataColumn(label: Text('2a vuelta'), numeric: true),
                                DataColumn(label: Text('Total'), numeric: true),
                                DataColumn(label: Text('Racimos/ha'), numeric: true),
                              ],
                              rows: [
                                ...filas.map((f) => DataRow(cells: [
                                      DataCell(Text(f.loteNombre)),
                                      DataCell(Text('${f.primera}')),
                                      DataCell(Text('${f.segunda}')),
                                      DataCell(Text('${f.total}')),
                                      DataCell(
                                          Text(f.racimosPorHa.toStringAsFixed(1))),
                                    ])),
                                DataRow(
                                  color: WidgetStateProperty.all(Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                                  cells: [
                                    const DataCell(Text('TOTAL',
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text('$totalPrimera',
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text('$totalSegunda',
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text('$totalGeneral',
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(
                                        totalRacimosPorHa.toStringAsFixed(1),
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (!completo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Faltan $lotesFaltantes lote(s) por registrar esta semana',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: completo && !_compartiendo
                            ? () => _compartirTabla(finca.nombre)
                            : null,
                        icon: _compartiendo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.share),
                        label: Text(_compartiendo
                            ? 'Generando...'
                            : 'Descargar imagen del reporte'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Identificar racimos'),
      ),
    );
  }
}
