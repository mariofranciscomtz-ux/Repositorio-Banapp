import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart' hide Column;
import '../../cinta_colores.dart';
import '../../data/powersync.dart';
import '../../data/sesion.dart' as sesion;
import '../../embolse_year.dart';
import '../../models/lote.dart';
import 'resumen_semanal_screen.dart';

/// Edades normales de corte, en semanas.
const _edadesCosecha = [8, 9, 10, 11, 12];

const _tiposDefecto = [
  'Daño animal',
  'Maduro',
  'Óxido rojo',
  'Sobre grado',
  'Bajo grado',
  'Daño de insecto',
  'Grasa',
  'Mancha de látex',
  'Deforme',
  'Mancha de madurez',
  'Quema de sol',
  'Sin cinta',
  'Caída de cable',
  'Maltrato',
  'Otro',
];

class _DefectoEntrada {
  String? tipo;
  final cantidadController = TextEditingController();
  final otroController = TextEditingController();
}

class _ViajeRow {
  final String id;
  final String loteId;
  final String loteNombre;
  final DateTime fecha;
  final DateTime horaRegistro;
  final String? operario;
  final Map<int, int> porEdad; // edad -> cantidad
  final Map<int, double?> porCalibracion; // edad -> calibración promedio
  final int recusados;

  _ViajeRow({
    required this.id,
    required this.loteId,
    required this.loteNombre,
    required this.fecha,
    required this.horaRegistro,
    required this.operario,
    required this.porEdad,
    required this.porCalibracion,
    required this.recusados,
  });

  int get totalRacimos =>
      porEdad.values.fold(0, (a, b) => a + b) + recusados;

  factory _ViajeRow.fromRow(dynamic row) => _ViajeRow(
        id: row['id'] as String,
        loteId: row['lote_id'] as String,
        loteNombre: row['lote_nombre'] as String,
        fecha: DateTime.parse(row['fecha'] as String),
        horaRegistro: DateTime.parse(row['hora_registro'] as String),
        operario: row['operario'] as String?,
        porEdad: {
          for (final e in _edadesCosecha) e: row['racimos_edad_$e'] as int,
        },
        porCalibracion: {
          for (final e in _edadesCosecha)
            e: (row['calibracion_edad_$e'] as num?)?.toDouble(),
        },
        recusados: row['racimos_recusados'] as int,
      );
}

/// Promedio ponderado (por cantidad de racimos) de calibración por edad,
/// a partir de un conjunto de viajes. Ignora los viajes donde no se
/// registró calibración para esa edad.
Map<int, double?> _promedioCalibracionPorEdad(Iterable<_ViajeRow> viajes) {
  final resultado = <int, double?>{};
  for (final e in _edadesCosecha) {
    double sumaPonderada = 0;
    int peso = 0;
    for (final v in viajes) {
      final cal = v.porCalibracion[e];
      final cant = v.porEdad[e] ?? 0;
      if (cal != null && cant > 0) {
        sumaPonderada += cal * cant;
        peso += cant;
      }
    }
    resultado[e] = peso > 0 ? sumaPonderada / peso : null;
  }
  return resultado;
}

class CosechaScreen extends StatefulWidget {
  const CosechaScreen({super.key});

  @override
  State<CosechaScreen> createState() => _CosechaScreenState();
}

class _CosechaScreenState extends State<CosechaScreen> {
  static String? _ultimoLoteId;

  Future<void> _abrirFormulario({_ViajeRow? existente}) async {
    final esEdicion = existente != null;
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

    Lote loteSeleccionado = esEdicion
        ? lotes.firstWhere((l) => l.id == existente.loteId,
            orElse: () => lotes.first)
        : lotes.firstWhere((l) => l.id == _ultimoLoteId,
            orElse: () => lotes.first);
    DateTime fecha = existente?.fecha ?? DateTime.now();
    TimeOfDay hora = existente != null
        ? TimeOfDay.fromDateTime(existente.horaRegistro)
        : TimeOfDay.now();
    final operarioController =
        TextEditingController(text: existente?.operario ?? '');
    final controllersPorEdad = {
      for (final e in _edadesCosecha)
        e: TextEditingController(
            text: (existente?.porEdad[e] ?? 0) > 0
                ? '${existente!.porEdad[e]}'
                : ''),
    };
    final controllersCalibracionPorEdad = {
      for (final e in _edadesCosecha)
        e: TextEditingController(
            text: existente?.porCalibracion[e] != null
                ? '${existente!.porCalibracion[e]}'
                : ''),
    };

    final defectos = <_DefectoEntrada>[];
    if (esEdicion) {
      final filas = await db.getAll(
        'SELECT tipo_defecto, cantidad FROM cosecha_viaje_defectos '
        'WHERE viaje_id = ?',
        [existente.id],
      );
      for (final fila in filas) {
        final tipoGuardado = fila['tipo_defecto'] as String;
        final entrada = _DefectoEntrada();
        if (_tiposDefecto.contains(tipoGuardado)) {
          entrada.tipo = tipoGuardado;
        } else {
          entrada.tipo = 'Otro';
          entrada.otroController.text = tipoGuardado;
        }
        entrada.cantidadController.text = '${fila['cantidad']}';
        defectos.add(entrada);
      }
    }
    if (defectos.isEmpty) defectos.add(_DefectoEntrada());

    if (!mounted) return;
    final creado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(esEdicion
              ? 'Editar viaje de cosecha'
              : 'Registrar viaje de cosecha'),
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
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final elegida = await showDatePicker(
                      context: context,
                      initialDate: fecha,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (elegida != null) {
                      setDialogState(() => fecha = elegida);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha del viaje',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}'),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final elegida = await showTimePicker(
                      context: context,
                      initialTime: hora,
                    );
                    if (elegida != null) {
                      setDialogState(() => hora = elegida);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Hora del viaje',
                      suffixIcon: Icon(Icons.access_time, size: 18),
                    ),
                    child: Text(hora.format(context)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: operarioController,
                  decoration: const InputDecoration(
                      labelText: 'Operario que transporta el viaje'),
                ),
                const SizedBox(height: 16),
                const Text('Racimos y calibración por edad',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._edadesCosecha.map((edad) {
                  final fechaIdentificacion =
                      fecha.subtract(Duration(days: edad * 7));
                  final color = colorCintaParaFecha(fechaIdentificacion);
                  final semana = isoWeekNumber(fechaIdentificacion);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cintaColores[color],
                            border: Border.all(
                                color: Colors.grey.shade500, width: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 82,
                          child: Text('$edad sem · S$semana',
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controllersPorEdad[edad],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Racimos',
                            ),
                            onChanged: (_) => setDialogState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controllersCalibracionPorEdad[edad],
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Calibr.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text('Racimos recusados (no procesables)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...defectos.asMap().entries.map((entry) {
                  final i = entry.key;
                  final d = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: d.tipo,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Tipo de defecto',
                                ),
                                items: _tiposDefecto
                                    .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t,
                                            overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: (v) =>
                                    setDialogState(() => d.tipo = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 64,
                              child: TextField(
                                controller: d.cantidadController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: '0',
                                ),
                                onChanged: (_) => setDialogState(() {}),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: defectos.length == 1
                                  ? null
                                  : () =>
                                      setDialogState(() => defectos.removeAt(i)),
                            ),
                          ],
                        ),
                        if (d.tipo == 'Otro')
                          Padding(
                            padding: const EdgeInsets.only(top: 4, right: 96),
                            child: TextField(
                              controller: d.otroController,
                              decoration: const InputDecoration(
                                isDense: true,
                                labelText: 'Especifica el defecto',
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () =>
                      setDialogState(() => defectos.add(_DefectoEntrada())),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar defecto'),
                ),
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  final porEdad = _edadesCosecha.fold<int>(
                      0,
                      (s, e) =>
                          s +
                          (int.tryParse(controllersPorEdad[e]!.text) ?? 0));
                  final porDefectos = defectos.fold<int>(
                      0,
                      (s, d) =>
                          s + (int.tryParse(d.cantidadController.text) ?? 0));
                  final total = porEdad + porDefectos;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total racimos en el viaje'),
                        Text('$total',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (creado != true) return;

    final cantidadesPorEdad = {
      for (final e in _edadesCosecha)
        e: int.tryParse(controllersPorEdad[e]!.text) ?? 0,
    };
    final calibracionesPorEdad = {
      for (final e in _edadesCosecha)
        e: double.tryParse(
            controllersCalibracionPorEdad[e]!.text.replaceAll(',', '.')),
    };

    // Solo cuentan los defectos con tipo elegido y cantidad > 0. Si es
    // "Otro" sin especificar, se descarta esa fila.
    final defectosValidos = <(String tipo, int cantidad)>[];
    for (final d in defectos) {
      final cantidad = int.tryParse(d.cantidadController.text) ?? 0;
      if (cantidad <= 0 || d.tipo == null) continue;
      final tipo = d.tipo == 'Otro' ? d.otroController.text.trim() : d.tipo!;
      if (tipo.isEmpty) continue;
      defectosValidos.add((tipo, cantidad));
    }
    final recusados =
        defectosValidos.fold<int>(0, (s, d) => s + d.$2);
    final total = cantidadesPorEdad.values.fold(0, (a, b) => a + b) + recusados;

    if (total == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registra al menos un racimo (por edad o recusado)'),
      ));
      return;
    }

    _ultimoLoteId = loteSeleccionado.id;
    final horaRegistro =
        DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute)
            .toIso8601String();
    final viajeId = existente?.id ?? uuid.v4();

    if (esEdicion) {
      await db.execute(
        'UPDATE cosecha_viajes SET lote_id = ?, fecha = ?, hora_registro = ?, '
        'operario = ?, racimos_edad_8 = ?, racimos_edad_9 = ?, racimos_edad_10 = ?, '
        'racimos_edad_11 = ?, racimos_edad_12 = ?, racimos_recusados = ?, '
        'calibracion_edad_8 = ?, calibracion_edad_9 = ?, calibracion_edad_10 = ?, '
        'calibracion_edad_11 = ?, calibracion_edad_12 = ? '
        'WHERE id = ?',
        [
          loteSeleccionado.id,
          dateOnly(fecha),
          horaRegistro,
          operarioController.text.isEmpty ? null : operarioController.text,
          cantidadesPorEdad[8],
          cantidadesPorEdad[9],
          cantidadesPorEdad[10],
          cantidadesPorEdad[11],
          cantidadesPorEdad[12],
          recusados,
          calibracionesPorEdad[8],
          calibracionesPorEdad[9],
          calibracionesPorEdad[10],
          calibracionesPorEdad[11],
          calibracionesPorEdad[12],
          viajeId,
        ],
      );
      await db.execute(
        'DELETE FROM cosecha_viaje_defectos WHERE viaje_id = ?',
        [viajeId],
      );
    } else {
      await db.execute(
        'INSERT INTO cosecha_viajes '
        '(id, lote_id, fecha, hora_registro, operario, '
        'racimos_edad_8, racimos_edad_9, racimos_edad_10, racimos_edad_11, racimos_edad_12, '
        'racimos_recusados, '
        'calibracion_edad_8, calibracion_edad_9, calibracion_edad_10, '
        'calibracion_edad_11, calibracion_edad_12) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          viajeId,
          loteSeleccionado.id,
          dateOnly(fecha),
          horaRegistro,
          operarioController.text.isEmpty ? null : operarioController.text,
          cantidadesPorEdad[8],
          cantidadesPorEdad[9],
          cantidadesPorEdad[10],
          cantidadesPorEdad[11],
          cantidadesPorEdad[12],
          recusados,
          calibracionesPorEdad[8],
          calibracionesPorEdad[9],
          calibracionesPorEdad[10],
          calibracionesPorEdad[11],
          calibracionesPorEdad[12],
        ],
      );
    }
    for (final d in defectosValidos) {
      await db.execute(
        'INSERT INTO cosecha_viaje_defectos (id, viaje_id, tipo_defecto, cantidad) '
        'VALUES (?, ?, ?, ?)',
        [uuid.v4(), viajeId, d.$1, d.$2],
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(esEdicion ? 'Viaje actualizado' : 'Viaje registrado'),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _eliminarViaje(_ViajeRow v) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar viaje'),
        content: Text(
            '¿Eliminar el viaje del lote ${v.loteNombre} con ${v.totalRacimos} racimos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await db.execute(
      'DELETE FROM cosecha_viaje_defectos WHERE viaje_id = ?',
      [v.id],
    );
    await db.execute('DELETE FROM cosecha_viajes WHERE id = ?', [v.id]);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Viaje eliminado'),
      duration: Duration(seconds: 2),
    ));
  }

  Future<void> _mostrarResumenPorLote() async {
    final finca = sesion.fincaSeleccionada.value!;
    final filas = await db.getAll(
      'SELECT l.nombre as lote_nombre, '
      'COUNT(*) as num_viajes, '
      'SUM(cv.racimos_edad_8) as edad_8, '
      'SUM(cv.racimos_edad_9) as edad_9, '
      'SUM(cv.racimos_edad_10) as edad_10, '
      'SUM(cv.racimos_edad_11) as edad_11, '
      'SUM(cv.racimos_edad_12) as edad_12, '
      'SUM(cv.racimos_recusados) as recusados, '
      'SUM(cv.racimos_edad_8 + cv.racimos_edad_9 + cv.racimos_edad_10 + '
      'cv.racimos_edad_11 + cv.racimos_edad_12 + cv.racimos_recusados) as total_racimos '
      'FROM cosecha_viajes cv '
      'JOIN lotes l ON l.id = cv.lote_id '
      'WHERE l.finca_id = ? '
      'GROUP BY l.nombre '
      'ORDER BY l.nombre',
      [finca.id],
    );

    if (!mounted) return;

    int sumar(String columna) =>
        filas.fold<int>(0, (s, f) => s + (f[columna] as int));
    final totalViajes = sumar('num_viajes');
    final totalPorEdad = {
      for (final e in _edadesCosecha) e: sumar('edad_$e'),
    };
    final totalRecusados = sumar('recusados');
    final totalRacimos = sumar('total_racimos');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen de cosecha por lote'),
        content: SizedBox(
          width: double.maxFinite,
          child: filas.isEmpty
              ? const Text('Sin viajes registrados todavía')
              : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('Lote')),
                        const DataColumn(label: Text('Viajes'), numeric: true),
                        ..._edadesCosecha.map((e) =>
                            DataColumn(label: Text('$e sem'), numeric: true)),
                        const DataColumn(
                            label: Text('Recus.'), numeric: true),
                        const DataColumn(
                            label: Text('Racimos'), numeric: true),
                      ],
                      rows: [
                        ...filas.map((f) => DataRow(cells: [
                              DataCell(Text(f['lote_nombre'] as String)),
                              DataCell(Text('${f['num_viajes']}')),
                              ..._edadesCosecha
                                  .map((e) => DataCell(Text('${f['edad_$e']}'))),
                              DataCell(Text('${f['recusados']}')),
                              DataCell(Text('${f['total_racimos']}')),
                            ])),
                        DataRow(
                          color: WidgetStateProperty.all(Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest),
                          cells: [
                            const DataCell(Text('Total',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('$totalViajes',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                            ..._edadesCosecha.map((e) => DataCell(Text(
                                '${totalPorEdad[e]}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))),
                            DataCell(Text('$totalRecusados',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text('$totalRacimos',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finca = sesion.fincaSeleccionada.value!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cosecha · ${finca.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_week_outlined),
            tooltip: 'Resumen semanal',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResumenSemanalScreen(finca: finca),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: 'Resumen por lote',
            onPressed: _mostrarResumenPorLote,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: db.watch(
          'SELECT cv.*, l.nombre as lote_nombre '
          'FROM cosecha_viajes cv '
          'JOIN lotes l ON l.id = cv.lote_id '
          'WHERE l.finca_id = ? '
          'ORDER BY cv.hora_registro DESC',
          parameters: [finca.id],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          final viajes =
              snapshot.data?.map(_ViajeRow.fromRow).toList() ?? const <_ViajeRow>[];
          if (viajes.isEmpty) {
            return const Center(child: Text('Sin viajes registrados todavía'));
          }

          final hoy = DateTime.now();
          final deHoy = viajes.where((v) =>
              v.fecha.year == hoy.year &&
              v.fecha.month == hoy.month &&
              v.fecha.day == hoy.day);
          final totalHoy = deHoy.fold<int>(
              0, (s, v) => s + v.porEdad.values.fold(0, (a, b) => a + b));
          final recusadosHoy = deHoy.fold<int>(0, (s, v) => s + v.recusados);
          final totalPorEdadHoy = {
            for (final e in _edadesCosecha)
              e: deHoy.fold<int>(0, (s, v) => s + (v.porEdad[e] ?? 0)),
          };
          final calibracionPorEdadHoy = _promedioCalibracionPorEdad(deHoy);

          return ListView(
            children: [
              if (deHoy.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ResumenTile(
                                  label: 'Racimos hoy', value: '$totalHoy'),
                              _ResumenTile(
                                  label: 'Recusados hoy',
                                  value: '$recusadosHoy'),
                              _ResumenTile(
                                  label: 'Viajes hoy',
                                  value: '${deHoy.length}'),
                            ],
                          ),
                          if (_edadesCosecha
                              .any((e) => (totalPorEdadHoy[e] ?? 0) > 0)) ...[
                            const Divider(height: 24),
                            ..._edadesCosecha
                                .where((e) => (totalPorEdadHoy[e] ?? 0) > 0)
                                .map((e) {
                              final calib = calibracionPorEdadHoy[e];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$e sem',
                                        style: const TextStyle(fontSize: 13)),
                                    Text('${totalPorEdadHoy[e]} racimos',
                                        style: const TextStyle(fontSize: 13)),
                                    Text(
                                        calib != null
                                            ? 'Calib. ${calib.toStringAsFixed(1)}'
                                            : 'Calib. —',
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ...viajes.map((v) {
                final hora =
                    '${v.horaRegistro.hour.toString().padLeft(2, '0')}:${v.horaRegistro.minute.toString().padLeft(2, '0')}';
                final detalle = _edadesCosecha
                    .where((e) => (v.porEdad[e] ?? 0) > 0)
                    .map((e) => '$e sem: ${v.porEdad[e]}')
                    .join(' · ');
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_shipping)),
                  title: Text(
                      'Lote ${v.loteNombre} · ${v.totalRacimos} racimos · $hora'),
                  subtitle: Text(
                    [
                      if (v.operario != null && v.operario!.isNotEmpty)
                        v.operario!,
                      if (detalle.isNotEmpty) detalle,
                      if (v.recusados > 0) 'Recusados: ${v.recusados}',
                    ].join(' · '),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (accion) {
                      if (accion == 'editar') {
                        _abrirFormulario(existente: v);
                      } else if (accion == 'eliminar') {
                        _eliminarViaje(v);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Eliminar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Registrar viaje'),
      ),
    );
  }
}

class _ResumenTile extends StatelessWidget {
  final String label;
  final String value;
  const _ResumenTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
