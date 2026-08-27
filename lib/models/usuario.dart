class Usuario {
  final String id;
  final String nombre;
  final String pinHash;

  Usuario({
    required this.id,
    required this.nombre,
    required this.pinHash,
  });

  factory Usuario.fromRow(dynamic row) => Usuario(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        pinHash: row['pin_hash'] as String,
      );
}
