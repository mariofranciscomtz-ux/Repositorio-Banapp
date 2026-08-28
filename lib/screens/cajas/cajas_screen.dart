import 'package:flutter/material.dart';
import '../../data/supabase_client.dart';
import '../../data/sesion.dart' as sesion;
import '../../embolse_year.dart';
import '../../models/caja_procesada.dart';
import '../../models/tipo_caja.dart';
import '../../widgets/app_logo.dart';

class CajasScreen extends StatefulWidget {
  const CajasScreen({super.key});

  @override
  State<CajasScreen> createState() => _CajasScreenState();
}

class _CajasScreenState extends State<CajasScreen> {
  Future<void> _abrirFormulario() async {
    final finca = sesion.fincaSeleccionada.value!;
    final tiposData =
        await supabase.from('tipos_caja').select().order('nombre');
    final tipos = tiposData.map(TipoCaja.fromRow).toList();

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
      await supabase.from('cajas_procesadas').insert({
        'finca_id': finca.id,
        'tipo_caja_id': tipoSeleccionado.id,
        'cantidad_cajas': cantidad,
        'fecha': dateOnly(DateTime.now()),
        'operario_id': sesion.usuarioActivo.value?.id,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finca = sesion.fincaSeleccionada.value!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Cajas procesadas · ${finca.nombre}',
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: supabase
            .from('tipos_caja')
            .stream(primaryKey: ['id']),
        builder: (context, tiposSnapshot) {
          if (tiposSnapshot.hasError) {
            return Center(
                child: Text('Error cargando datos: ${tiposSnapshot.error}'));
          }
          if (!tiposSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tiposPorId = {
            for (final t in tiposSnapshot.data!.map(TipoCaja.fromRow)) t.id: t,
          };

          return StreamBuilder(
            stream: supabase
                .from('cajas_procesadas')
                .stream(primaryKey: ['id']).eq('finca_id', finca.id),
            builder: (context, cajasSnapshot) {
              if (cajasSnapshot.hasError) {
                return Center(
                    child:
                        Text('Error cargando datos: ${cajasSnapshot.error}'));
              }
              final cajas = (cajasSnapshot.data ?? const [])
                  .where((r) => tiposPorId.containsKey(r['tipo_caja_id']))
                  .map((r) => CajaProcesada.desdeRegistro(
                        r,
                        fincaNombre: finca.nombre,
                        tipoCaja: tiposPorId[r['tipo_caja_id']]!,
                      ))
                  .toList()
                ..sort((a, b) => b.fecha.compareTo(a.fecha));

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
