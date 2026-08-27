import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/pin_hash.dart';
import '../data/supabase_client.dart';
import '../data/sesion.dart';
import '../models/finca.dart';
import '../models/usuario.dart';
import '../saludo.dart';

class SeleccionarFincaScreen extends StatefulWidget {
  const SeleccionarFincaScreen({super.key});

  @override
  State<SeleccionarFincaScreen> createState() =>
      _SeleccionarFincaScreenState();
}

class _SeleccionarFincaScreenState extends State<SeleccionarFincaScreen> {
  String? _seleccionId;

  Future<void> _crearUsuario() async {
    final usuariosData = await supabase.from('usuarios').select();
    final usuarios = usuariosData.map(Usuario.fromRow).toList();

    final nombreController = TextEditingController();
    final pinController = TextEditingController();
    final pinConfirmController = TextEditingController();
    String? errorDialog;

    if (!mounted) return;
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
      await supabase.from('usuarios').insert({
        'nombre': nombreController.text.trim(),
        'pin_hash': hashPin(pinController.text),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Usuario "${nombreController.text.trim()}" creado. Ya puede iniciar sesión con su PIN.'),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saludo = saludoSegunHora();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(saludo.icono, size: 32, color: colorScheme.primary),
                        const SizedBox(height: 10),
                        Text(
                          saludo.texto,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¿En qué finca vas a trabajar hoy?',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: usuarioActivo,
                    builder: (context, usuario, _) {
                      if (usuario == null) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.person_outline),
                        tooltip: 'Cambiar usuario (${usuario.nombre})',
                        onPressed: () => usuarioActivo.value = null,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: supabase.from('fincas').stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error cargando fincas: ${snapshot.error}'));
                  }
                  final fincas = (snapshot.data ?? const [])
                      .map(Finca.fromRow)
                      .toList()
                    ..sort((a, b) {
                      final ordenA = a.orden ?? 1 << 30;
                      final ordenB = b.orden ?? 1 << 30;
                      final cmp = ordenA.compareTo(ordenB);
                      return cmp != 0 ? cmp : a.nombre.compareTo(b.nombre);
                    });
                  if (fincas.isEmpty) {
                    return const Center(child: Text('No hay fincas registradas'));
                  }

                  final seleccionValida =
                      fincas.any((f) => f.id == _seleccionId);
                  final idActual = seleccionValida ? _seleccionId : null;
                  final fincaActual = seleccionValida
                      ? fincas.firstWhere((f) => f.id == _seleccionId)
                      : null;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Finca',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: idActual,
                          decoration: InputDecoration(
                            hintText: 'Selecciona una finca',
                            prefixIcon: const Icon(Icons.agriculture),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: fincas
                              .map((f) => DropdownMenuItem(
                                    value: f.id,
                                    child: Text(f.nombre),
                                  ))
                              .toList(),
                          onChanged: (id) => setState(() => _seleccionId = id),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: fincaActual == null
                              ? null
                              : () => fincaSeleccionada.value = fincaActual,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Continuar'),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _crearUsuario,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Crear usuario nuevo'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
