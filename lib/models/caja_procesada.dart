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

  factory CajaProcesada.fromRow(dynamic row) => CajaProcesada(
        id: row['id'] as String,
        fincaNombre: row['finca_nombre'] as String,
        tipoCajaNombre: row['tipo_caja_nombre'] as String,
        pesoNetoKg: (row['peso_neto_kg'] as num).toDouble(),
        cantidadCajas: row['cantidad_cajas'] as int,
        fecha: DateTime.parse(row['fecha'] as String),
      );
}
