class BackendUser {
  final int id;
  final String firebaseUid;
  final String correo;
  final String nombreUsuario;
  final String nombreCompleto;
  final String rol; // 'aprendiz', 'editor', 'administrador'
  final bool activo;
  final String? creadoEn;
  final String? actualizadoEn;

  BackendUser({
    required this.id,
    required this.firebaseUid,
    required this.correo,
    required this.nombreUsuario,
    required this.nombreCompleto,
    required this.rol,
    required this.activo,
    this.creadoEn,
    this.actualizadoEn,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) {
    return BackendUser(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      firebaseUid: json['firebase_uid'] ?? '',
      correo: json['correo'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      rol: json['rol'] ?? 'aprendiz',
      activo: json['activo'] ?? true,
      creadoEn: json['creado_en']?.toString(),
      actualizadoEn: json['actualizado_en']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'correo': correo,
      'nombre_usuario': nombreUsuario,
      'nombre_completo': nombreCompleto,
      'rol': rol,
      'activo': activo,
      'creado_en': creadoEn,
      'actualizado_en': actualizadoEn,
    };
  }

  BackendUser copyWith({
    int? id,
    String? firebaseUid,
    String? correo,
    String? nombreUsuario,
    String? nombreCompleto,
    String? rol,
    bool? activo,
    String? creadoEn,
    String? actualizadoEn,
  }) {
    return BackendUser(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      correo: correo ?? this.correo,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }
}

/// Role hierarchy: aprendiz (1) < editor (2) < administrador (3)
int getRoleLevel(String rol) {
  switch (rol.toLowerCase()) {
    case 'administrador':
      return 3;
    case 'editor':
      return 2;
    case 'aprendiz':
    default:
      return 1;
  }
}

bool tieneRol(BackendUser? user, String rolMinimo) {
  if (user == null) return false;
  return getRoleLevel(user.rol) >= getRoleLevel(rolMinimo);
}

bool esEditor(BackendUser? user) => tieneRol(user, 'editor');

bool esAdministrador(BackendUser? user) => tieneRol(user, 'administrador');
