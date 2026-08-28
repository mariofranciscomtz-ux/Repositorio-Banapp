import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClimaActual {
  final double temperaturaC;
  final double sensacionTermicaC;
  final int humedadPct;
  final double precipitacionMm;
  final String descripcion;
  final IconData icono;
  final List<PronosticoDia> proximosDias;

  ClimaActual({
    required this.temperaturaC,
    required this.sensacionTermicaC,
    required this.humedadPct,
    required this.precipitacionMm,
    required this.descripcion,
    required this.icono,
    required this.proximosDias,
  });
}

class PronosticoDia {
  final DateTime fecha;
  final double tempMaxC;
  final double tempMinC;
  final double precipitacionMm;
  final String descripcion;
  final IconData icono;

  PronosticoDia({
    required this.fecha,
    required this.tempMaxC,
    required this.tempMinC,
    required this.precipitacionMm,
    required this.descripcion,
    required this.icono,
  });
}

class ClimaService {
  static Future<ClimaActual> obtenerClimaActual({
    required double latitud,
    required double longitud,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitud&longitude=$longitud'
      '&current=temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,weather_code'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code'
      '&forecast_days=4'
      '&timezone=auto',
    );

    final respuesta = await http.get(uri).timeout(const Duration(seconds: 10));
    if (respuesta.statusCode != 200) {
      throw Exception('Error consultando el clima (${respuesta.statusCode})');
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final actual = datos['current'] as Map<String, dynamic>;
    final codigo = actual['weather_code'] as int;
    final (descripcion, icono) = _interpretarCodigo(codigo);

    final diario = datos['daily'] as Map<String, dynamic>;
    final fechas = diario['time'] as List;
    final tempMax = diario['temperature_2m_max'] as List;
    final tempMin = diario['temperature_2m_min'] as List;
    final precipitacion = diario['precipitation_sum'] as List;
    final codigosDiarios = diario['weather_code'] as List;

    // El índice 0 del arreglo diario es hoy; se muestran los 3 días
    // siguientes.
    final proximosDias = <PronosticoDia>[];
    for (var i = 1; i < fechas.length; i++) {
      final (desc, ic) = _interpretarCodigo(codigosDiarios[i] as int);
      proximosDias.add(PronosticoDia(
        fecha: DateTime.parse(fechas[i] as String),
        tempMaxC: (tempMax[i] as num).toDouble(),
        tempMinC: (tempMin[i] as num).toDouble(),
        precipitacionMm: (precipitacion[i] as num).toDouble(),
        descripcion: desc,
        icono: ic,
      ));
    }

    return ClimaActual(
      temperaturaC: (actual['temperature_2m'] as num).toDouble(),
      sensacionTermicaC: (actual['apparent_temperature'] as num).toDouble(),
      humedadPct: (actual['relative_humidity_2m'] as num).round(),
      precipitacionMm: (actual['precipitation'] as num).toDouble(),
      descripcion: descripcion,
      icono: icono,
      proximosDias: proximosDias,
    );
  }

  static (String, IconData) _interpretarCodigo(int codigo) {
    return switch (codigo) {
      0 => ('Despejado', Icons.wb_sunny),
      1 || 2 => ('Parcialmente nublado', Icons.wb_cloudy),
      3 => ('Nublado', Icons.cloud),
      45 || 48 => ('Neblina', Icons.foggy),
      51 || 53 || 55 => ('Llovizna', Icons.grain),
      56 || 57 => ('Llovizna helada', Icons.grain),
      61 || 63 || 65 => ('Lluvia', Icons.water_drop),
      66 || 67 => ('Lluvia helada', Icons.water_drop),
      71 || 73 || 75 || 77 => ('Nieve', Icons.ac_unit),
      80 || 81 || 82 => ('Chubascos', Icons.beach_access),
      85 || 86 => ('Chubascos de nieve', Icons.ac_unit),
      95 => ('Tormenta eléctrica', Icons.thunderstorm),
      96 || 99 => ('Tormenta con granizo', Icons.thunderstorm),
      _ => ('Sin datos', Icons.help_outline),
    };
  }
}
