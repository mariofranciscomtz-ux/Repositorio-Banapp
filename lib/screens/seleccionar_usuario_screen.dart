import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/pin_hash.dart';
import '../data/supabase_client.dart';
import '../data/sesion.dart';
import '../models/usuario.dart';
import '../saludo.dart';
import '../widgets/app_logo.dart';

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
    final saludo = saludoSegunHora();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(colorScheme.primary, Colors.white, 0.12)!,
              Color.lerp(colorScheme.primary, Colors.black, 0.55)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                    child: StreamBuilder(
                      stream: supabase.from('usuarios').stream(primaryKey: ['id']),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                              'Error cargando usuarios: ${snapshot.error}');
                        }
                        final usuarios = (snapshot.data ?? const [])
                            .map(Usuario.fromRow)
                            .toList()
                          ..sort((a, b) => a.nombre.compareTo(b.nombre));
                        final seleccionValida =
                            usuarios.any((u) => u.id == _usuarioId);
                        final idActual = seleccionValida ? _usuarioId : null;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: AppLogo(size: 88)),
                            const SizedBox(height: 16),
                            Text(
                              'Banapp',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              saludo.texto,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Usuario',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: idActual,
                              decoration: const InputDecoration(
                                hintText: 'Selecciona tu usuario',
                                prefixIcon: Icon(Icons.person_outline),
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
                            const SizedBox(height: 18),
                            Text(
                              'PIN',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _pinController,
                              decoration: const InputDecoration(
                                hintText: '4 dígitos',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => idActual == null
                                  ? null
                                  : _ingresar(usuarios),
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: (idActual == null ||
                                      _pinController.text.length != 4)
                                  ? null
                                  : () => _ingresar(usuarios),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Iniciar sesión'),
                            ),
                            if (usuarios.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  'No hay usuarios registrados todavía. Pide '
                                  'a un administrador que te cree uno desde '
                                  'Configuración.',
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
