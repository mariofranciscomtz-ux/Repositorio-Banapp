import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/pin_hash.dart';
import '../data/supabase_client.dart';
import '../data/sesion.dart';
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
    final nombreController = TextEditingController();
    final pinController = TextEditingController();
    final pinConfirmController = TextEditingController();
    String? errorDialog;

    final creado = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
              if (errorDialog != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(errorDialog!,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
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
      setState(() => _usuarioId = inserted['id'] as String);
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
