import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/pin_hash.dart';
import '../data/supabase_client.dart';
import '../models/finca.dart';
import '../models/usuario.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  Future<List<Finca>> _cargarFincas() async {
    final data = await supabase.from('fincas').select().order('nombre');
    return data.map(Finca.fromRow).toList();
  }

  Future<void> _crearUsuario(List<Usuario> usuarios) async {
    final fincas = await _cargarFincas();
    if (!mounted) return;

    final nombreController = TextEditingController();
    final pinController = TextEditingController();
    final pinConfirmController = TextEditingController();
    final fincasSeleccionadas = <String>{};
    String? errorDialog;

    final creado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  decoration: const InputDecoration(labelText: 'PIN (4 dígitos)'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(
                  controller: pinConfirmController,
                  decoration:
                      const InputDecoration(labelText: 'Confirmar PIN'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                Text('Fincas a las que tendrá acceso',
                    style: Theme.of(context).textTheme.labelLarge),
                if (fincas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('No hay fincas registradas todavía'),
                  )
                else
                  ...fincas.map((f) => CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(f.nombre),
                        value: fincasSeleccionadas.contains(f.id),
                        onChanged: (marcado) => setDialogState(() {
                          if (marcado == true) {
                            fincasSeleccionadas.add(f.id);
                          } else {
                            fincasSeleccionadas.remove(f.id);
                          }
                        }),
                      )),
                if (errorDialog != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(errorDialog!,
                        style: const TextStyle(color: Colors.red)),
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
              onPressed: () {
                final nombre = nombreController.text.trim();
                if (nombre.isEmpty) {
                  setDialogState(() => errorDialog = 'Escribe un nombre');
                  return;
                }
                if (usuarios.any(
                    (u) => u.nombre.toLowerCase() == nombre.toLowerCase())) {
                  setDialogState(
                      () => errorDialog = 'Ya existe un usuario con ese nombre');
                  return;
                }
                if (pinController.text.length != 4) {
                  setDialogState(() => errorDialog = 'El PIN debe tener 4 dígitos');
                  return;
                }
                if (pinController.text != pinConfirmController.text) {
                  setDialogState(() => errorDialog = 'Los PIN no coinciden');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    if (creado == true) {
      final inserted = await supabase
          .from('usuarios')
          .insert({
            'nombre': nombreController.text.trim(),
            'pin_hash': hashPin(pinController.text),
          })
          .select()
          .single();
      final nuevoId = inserted['id'] as String;
      if (fincasSeleccionadas.isNotEmpty) {
        await supabase.from('usuario_fincas').insert(
              fincasSeleccionadas
                  .map((fincaId) => {'usuario_id': nuevoId, 'finca_id': fincaId})
                  .toList(),
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usuario "${nombreController.text.trim()}" creado'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _editarPermisos(Usuario usuario) async {
    final fincas = await _cargarFincas();
    final permisosData = await supabase
        .from('usuario_fincas')
        .select('finca_id')
        .eq('usuario_id', usuario.id);
    final actuales =
        permisosData.map((r) => r['finca_id'] as String).toSet();
    final seleccion = Set<String>.from(actuales);

    if (!mounted) return;
    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Fincas de ${usuario.nombre}'),
          content: SizedBox(
            width: double.maxFinite,
            child: fincas.isEmpty
                ? const Text('No hay fincas registradas todavía')
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: fincas
                          .map((f) => CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(f.nombre),
                                value: seleccion.contains(f.id),
                                onChanged: (marcado) => setDialogState(() {
                                  if (marcado == true) {
                                    seleccion.add(f.id);
                                  } else {
                                    seleccion.remove(f.id);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
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

    if (guardar != true) return;

    final aQuitar = actuales.difference(seleccion);
    final aAgregar = seleccion.difference(actuales);
    if (aQuitar.isNotEmpty) {
      await supabase
          .from('usuario_fincas')
          .delete()
          .eq('usuario_id', usuario.id)
          .inFilter('finca_id', aQuitar.toList());
    }
    if (aAgregar.isNotEmpty) {
      await supabase.from('usuario_fincas').insert(
            aAgregar
                .map((fincaId) =>
                    {'usuario_id': usuario.id, 'finca_id': fincaId})
                .toList(),
          );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Permisos actualizados'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración · Usuarios')),
      body: StreamBuilder(
        stream: supabase.from('usuarios').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error cargando usuarios: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuarios = snapshot.data!.map(Usuario.fromRow).toList()
            ..sort((a, b) => a.nombre.compareTo(b.nombre));

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: usuarios.map((u) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(u.esAdmin ? Icons.shield : Icons.person),
                ),
                title: Text(u.nombre),
                subtitle: Text(u.esAdmin
                    ? 'Administrador · acceso a todas las fincas'
                    : 'Acceso solo a las fincas asignadas'),
                trailing: u.esAdmin
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar fincas asignadas',
                        onPressed: () => _editarPermisos(u),
                      ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: StreamBuilder(
        stream: supabase.from('usuarios').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          final usuarios =
              (snapshot.data ?? const []).map(Usuario.fromRow).toList();
          return FloatingActionButton.extended(
            onPressed: () => _crearUsuario(usuarios),
            icon: const Icon(Icons.person_add),
            label: const Text('Nuevo usuario'),
          );
        },
      ),
    );
  }
}
