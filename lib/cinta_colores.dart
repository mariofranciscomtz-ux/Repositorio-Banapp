import 'package:flutter/material.dart';

/// Ciclo real de colores de cinta de la empresa. El año de embolse arranca
/// en la semana ISO 42 del año calendario anterior, siempre con Amarillo.
const cintaCiclo = [
  'Amarillo',
  'Blanco',
  'Azul',
  'Rojo',
  'Café',
  'Negro',
  'Naranja',
  'Verde',
];

const cintaColores = <String, Color>{
  'Amarillo': Color(0xFFFFD600),
  'Blanco': Color(0xFFFFFFFF),
  'Azul': Color(0xFF1565C0),
  'Rojo': Color(0xFFD32F2F),
  'Café': Color(0xFF6D4C41),
  'Negro': Color(0xFF212121),
  'Naranja': Color(0xFFF57C00),
  'Verde': Color(0xFF2E7D32),
};

// Lunes que inicia la semana ISO 42 de 2026 = Amarillo (índice 0).
final _anclaCiclo = DateTime(2026, 10, 12);

int _floorDiv(int a, int b) {
  final q = a ~/ b;
  return (a % b != 0 && (a < 0) != (b < 0)) ? q - 1 : q;
}

/// Color de cinta que le corresponde a una fecha según el ciclo de 8 semanas.
String colorCintaParaFecha(DateTime fecha) {
  final dia = DateTime(fecha.year, fecha.month, fecha.day);
  final dias = dia.difference(_anclaCiclo).inDays;
  final semanas = _floorDiv(dias, 7);
  final idx = ((semanas % cintaCiclo.length) + cintaCiclo.length) % cintaCiclo.length;
  return cintaCiclo[idx];
}

/// Lunes a miércoles = primera vuelta; jueves a sábado (y domingo) = segunda.
String vueltaParaFecha(DateTime fecha) {
  return fecha.weekday <= DateTime.wednesday ? 'primera' : 'segunda';
}
