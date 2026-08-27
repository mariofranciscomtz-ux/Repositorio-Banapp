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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Quién eres?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar finca',
            onPressed: () => fincaSeleccionada.value = null,
          ),
        ],
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
                if (usuarios.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Aún no hay usuarios registrados en este dispositivo. '
                      'Toca "Cambiar finca" arriba y crea el primero desde ahí.',
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
