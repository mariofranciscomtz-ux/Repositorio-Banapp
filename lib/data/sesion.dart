import 'package:flutter/foundation.dart';
import '../models/finca.dart';
import '../models/usuario.dart';

/// Finca elegida para trabajar en esta sesión. Se pide de nuevo en cada
/// inicio de sesión (no se guarda en el dispositivo).
final fincaSeleccionada = ValueNotifier<Finca?>(null);

/// Trabajador identificado en este dispositivo (nombre + PIN). Se pide de
/// nuevo en cada inicio de sesión, igual que la finca.
final usuarioActivo = ValueNotifier<Usuario?>(null);
