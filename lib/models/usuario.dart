class Usuario {
  final String id;
  final String nombre;
  final String pinHash;
  final bool esAdmin;

  Usuario({
    required this.id,
    required this.nombre,
    required this.pinHash,
    required this.esAdmin,
  });

  factory Usuario.fromRow(dynamic row) => Usuario(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        pinHash: row['pin_hash'] as String,
        esAdmin: row['es_admin'] as bool? ?? false,
      );
}
