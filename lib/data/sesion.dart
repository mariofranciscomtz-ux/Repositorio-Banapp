import 'package:flutter/foundation.dart';
import '../models/finca.dart';

/// Finca elegida para trabajar en esta sesión. Se pide de nuevo en cada
/// inicio de sesión (no se guarda en el dispositivo).
final fincaSeleccionada = ValueNotifier<Finca?>(null);
