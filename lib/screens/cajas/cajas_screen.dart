import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart' hide Column;
import '../../data/powersync.dart';
import '../../data/sesion.dart' as sesion;
import '../../embolse_year.dart';
import '../../models/caja_procesada.dart';
import '../../models/tipo_caja.dart';

class CajasScreen extends StatefulWidget {
  const CajasScreen({super.key});

  @override
  State<CajasScreen> createState() => _CajasScreenState();
}

class _CajasScreenState extends State<CajasScreen> {
  Future<void> _abrirFormulario() async {
    final finca = sesion.fincaSeleccionada.value!;
    final tipos = (await db.getAll('SELECT * FROM tipos_caja ORDER BY nombre'))
        .map(TipoCaja.fromRow)
        .toList();

    if (tipos.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No hay tipos de caja registrados'),
      ));
      return;
    }

    TipoCaja tipoSeleccionado = tipos.first;
    final cantidadController = TextEditingController();

    if (!mounted) return;
    final creado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar cajas procesadas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TipoCaja>(
                initialValue: tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo de caja'),
                items: tipos
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text('${t.nombre} (${t.pesoNetoKg} kg neto)'),
                        ))
                    .toList(),
                onChanged: (t) => setDialogState(() => tipoSeleccionado = t!),
              ),
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Cantidad de cajas'),
              ),
            ],
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

    final cantidad = int.tryParse(cantidadController.text);
    if (creado == true && cantidad != null) {
      await db.execute(
        'INSERT INTO cajas_procesadas (id, finca_id, tipo_caja_id, cantidad_cajas, fecha, operario_id) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          uuid.v4(),
          finca.id,
          tipoSeleccionado.id,
          cantidad,
          dateOnly(DateTime.now()),
          sesion.usuarioActivo.value?.id,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final finca = sesion.fincaSeleccionada.value!;
    return Scaffold(
      appBar: AppBar(title: Text('Cajas procesadas · ${finca.nombre}')),
      body: StreamBuilder(
        stream: db.watch(
          'SELECT cp.*, f.nombre as finca_nombre, t.nombre as tipo_caja_nombre, '
          't.peso_neto_kg FROM cajas_procesadas cp '
          'JOIN fincas f ON f.id = cp.finca_id '
          'JOIN tipos_caja t ON t.id = cp.tipo_caja_id '
          'WHERE cp.finca_id = ? '
          'ORDER BY cp.fecha DESC',
          parameters: [finca.id],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          final cajas = snapshot.data?.map(CajaProcesada.fromRow).toList() ??
              const <CajaProcesada>[];
          final totalCajas =
              cajas.fold<int>(0, (sum, c) => sum + c.cantidadCajas);
          final totalEquivalentes =
              cajas.fold<double>(0, (sum, c) => sum + c.cajasEquivalentes185);

          return Column(
            children: [
              if (cajas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Total: $totalCajas cajas físicas · ${totalEquivalentes.toStringAsFixed(1)} cajas equiv. 18.5 kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              Expanded(
                child: cajas.isEmpty
                    ? const Center(child: Text('Sin cajas registradas todavía'))
                    : ListView.builder(
                        itemCount: cajas.length,
                        itemBuilder: (context, index) {
                          final c = cajas[index];
                          return ListTile(
                            leading: const Icon(Icons.inventory_2),
                            title: Text(
                                '${c.tipoCajaNombre} · ${c.cantidadCajas} cajas'),
                            subtitle: Text(
                                '${c.pesoNetoTotalKg.toStringAsFixed(1)} kg neto · ${c.cajasEquivalentes185.toStringAsFixed(1)} equiv. 18.5'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
