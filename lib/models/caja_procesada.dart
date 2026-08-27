import 'tipo_caja.dart';

class CajaProcesada {
  final String id;
  final String fincaNombre;
  final String tipoCajaNombre;
  final double pesoNetoKg;
  final int cantidadCajas;
  final DateTime fecha;

  CajaProcesada({
    required this.id,
    required this.fincaNombre,
    required this.tipoCajaNombre,
    required this.pesoNetoKg,
    required this.cantidadCajas,
    required this.fecha,
  });

  double get pesoNetoTotalKg => cantidadCajas * pesoNetoKg;
  double get cajasEquivalentes185 => pesoNetoTotalKg / 18.5;

  factory CajaProcesada.desdeRegistro(
    dynamic row, {
    required String fincaNombre,
    required TipoCaja tipoCaja,
  }) =>
      CajaProcesada(
        id: row['id'] as String,
        fincaNombre: fincaNombre,
        tipoCajaNombre: tipoCaja.nombre,
        pesoNetoKg: tipoCaja.pesoNetoKg,
        cantidadCajas: row['cantidad_cajas'] as int,
        fecha: DateTime.parse(row['fecha'] as String),
      );
}
