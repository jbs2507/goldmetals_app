// Autenticación TEMPORAL en memoria. Reemplazar por el backend.

/// Roles permitidos en la app.
const List<String> rolesApp = ['Administrador', 'Contador', 'Abogado'];

class Usuario {
  Usuario(this.nombre, this.correo, this.telefono, this.clave, this.estado, this.rol);
  String nombre, correo, telefono, clave, estado, rol;
}

class AuthResult {
  AuthResult.ok(this.usuario) : ok = true, campo = null, error = null;
  AuthResult.fail(this.error, {this.campo}) : ok = false, usuario = null;
  final bool ok;
  final String? campo, error;
  final Usuario? usuario;
}

// Usuarios de prueba, uno por rol.
final List<Usuario> _usuarios = [
  Usuario('Administrador', 'admin@mmmetalsgold.com', '3001234567', 'Admin12345', 'ACTIVO', 'Administrador'),
  Usuario('Contador', 'contador@mmmetalsgold.com', '3012345678', 'Contador123', 'ACTIVO', 'Contador'),
  Usuario('Abogado', 'abogado@mmmetalsgold.com', '3023456789', 'Abogado123', 'ACTIVO', 'Abogado'),
];

Usuario? sesion;

bool _igual(String a, String b) => a.trim().toLowerCase() == b.trim().toLowerCase();

/// El registro no pide rol: la cuenta queda "Sin asignar" hasta que un
/// administrador le asigne Administrador, Contador o Abogado.
AuthResult registrarUsuario(String nombre, String correo, String telefono, String clave) {
  if (_usuarios.any((u) => _igual(u.correo, correo))) return AuthResult.fail('Este correo ya está registrado', campo: 'correo');
  final u = Usuario(nombre.trim(), correo.trim(), telefono.trim(), clave, 'ACTIVO', 'Sin asignar');
  _usuarios.add(u);
  return AuthResult.ok(u);
}

AuthResult autenticar(String correo, String clave) {
  final i = _usuarios.indexWhere((u) => _igual(u.correo, correo));
  if (i < 0) return AuthResult.fail('Este correo no está registrado', campo: 'correo');
  final u = _usuarios[i];
  if (u.estado == 'INACTIVO') return AuthResult.fail('Tu usuario está inactivo. Contacta al administrador.');
  if (u.clave != clave) return AuthResult.fail('Contraseña incorrecta', campo: 'clave');
  return AuthResult.ok(u);
}

String iniciales(String nombre) {
  final p = nombre.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return 'U';
  return (p[0][0] + (p.length > 1 ? p[1][0] : '')).toUpperCase();
}
