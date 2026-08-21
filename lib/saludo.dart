import 'package:flutter/material.dart';

({String texto, IconData icono}) saludoSegunHora([DateTime? ahora]) {
  final hora = (ahora ?? DateTime.now()).hour;
  if (hora >= 5 && hora < 12) {
    return (texto: 'Buenos días amigo bananero', icono: Icons.wb_sunny);
  }
  if (hora >= 12 && hora < 18) {
    return (texto: 'Buenas tardes amigo bananero', icono: Icons.wb_cloudy);
  }
  return (texto: 'Buenas noches amigo bananero', icono: Icons.nights_stay);
}
