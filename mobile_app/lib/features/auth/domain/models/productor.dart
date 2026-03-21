class Productor {
  final String productorId;
  final String uidAuth;
  final String nombreCompleto;
  final String correo;
  final String? telefono;
  final String estadoCuenta;

  Productor({
    required this.productorId,
    required this.uidAuth,
    required this.nombreCompleto,
    required this.correo,
    this.telefono,
    required this.estadoCuenta,
  });

  Map<String, dynamic> toMap() {
    return {
      'productorId': productorId,
      'uidAuth': uidAuth,
      'nombreCompleto': nombreCompleto,
      'correo': correo,
      'telefono': telefono,
      'estadoCuenta': estadoCuenta,
    };
  }
}