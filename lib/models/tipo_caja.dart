class TipoCaja {
  final String id;
  final String nombre;
  final double pesoBrutoKg;
  final double pesoNetoKg;

  TipoCaja({
    required this.id,
    required this.nombre,
    required this.pesoBrutoKg,
    required this.pesoNetoKg,
  });

  factory TipoCaja.fromRow(dynamic row) => TipoCaja(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        pesoBrutoKg: (row['peso_bruto_kg'] as num).toDouble(),
        pesoNetoKg: (row['peso_neto_kg'] as num).toDouble(),
      );
}
