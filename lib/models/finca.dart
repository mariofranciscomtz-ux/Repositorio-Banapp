class Finca {
  final String id;
  final String nombre;

  Finca({required this.id, required this.nombre});

  factory Finca.fromRow(dynamic row) => Finca(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
      );
}
