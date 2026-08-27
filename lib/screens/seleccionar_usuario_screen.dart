import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/pin_hash.dart';
import '../data/supabase_client.dart';
import '../data/sesion.dart';
import '../models/finca.dart';
import '../models/usuario.dart';

class SeleccionarUsuarioScreen extends StatefulWidget {
  const SeleccionarUsuarioScreen({super.key});

  @override
  State<SeleccionarUsuarioScreen> createState() =>
      _SeleccionarUsuarioScreenState();
}

class _SeleccionarUsuarioScreenState extends State<SeleccionarUsuarioScreen> {
  String? _usuarioId;
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _ingresar(List<Usuario> usuarios) async {
    final usuario = usuarios.firstWhere((u) => u.id == _usuarioId);
    if (hashPin(_pinController.text) != usuario.pinHash) {
      setState(() => _error = 'PIN incorrecto');
      return;
    }
    usuarioActivo.value = usuario;
  }

  Future<void> _crearUsuario(List<Usuario> usuarios) async {
    final fincasData = await supabase.from('fincas').select().order('nombre');
    final fincas = fincasData.map(Finca.fromRow).toList();

    final nombreController = TextEditingController();
    final pinController = TextEditingController();
    final pinConfirmController = TextEditingController();
    final fincasSeleccionadas = <String>{};
    String? errorDialog;

    if (!mounted) return;
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
      setState(() => _usuarioId = nuevoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Quién eres?'),
      ),
      body: StreamBuilder(
        stream: supabase.from('usuarios').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error cargando usuarios: ${snapshot.error}'));
          }
          final usuarios = (snapshot.data ?? const [])
              .map(Usuario.fromRow)
              .toList()
            ..sort((a, b) => a.nombre.compareTo(b.nombre));
          final seleccionValida = usuarios.any((u) => u.id == _usuarioId);
          final idActual = seleccionValida ? _usuarioId : null;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: idActual,
                  decoration: InputDecoration(
                    hintText: 'Selecciona tu usuario',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: usuarios
                      .map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.nombre),
                          ))
                      .toList(),
                  onChanged: (id) => setState(() {
                    _usuarioId = id;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    prefixIcon: Icon(Icons.pin),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) =>
                      idActual == null ? null : _ingresar(usuarios),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: (idActual == null || _pinController.text.length != 4)
                      ? null
                      : () => _ingresar(usuarios),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ingresar'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _crearUsuario(usuarios),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Crear usuario nuevo'),
                ),
                if (usuarios.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Aún no hay usuarios registrados en este dispositivo. Crea el primero.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
