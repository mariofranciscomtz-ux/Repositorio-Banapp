class Finca {
  final String id;
  final String nombre;
  final double? latitud;
  final double? longitud;

  Finca({
    required this.id,
    required this.nombre,
    this.latitud,
    this.longitud,
  });

  factory Finca.fromRow(dynamic row) => Finca(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        latitud: (row['latitud'] as num?)?.toDouble(),
        longitud: (row['longitud'] as num?)?.toDouble(),
      );
}
