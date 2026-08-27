class Lote {
  final String id;
  final String fincaId;
  final String nombre;
  final double hectareas;

  Lote({
    required this.id,
    required this.fincaId,
    required this.nombre,
    required this.hectareas,
  });

  factory Lote.fromRow(dynamic row) => Lote(
        id: row['id'] as String,
        fincaId: row['finca_id'] as String,
        nombre: row['nombre'] as String,
        hectareas: (row['hectareas'] as num).toDouble(),
      );
}
