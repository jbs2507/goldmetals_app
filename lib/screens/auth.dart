import 'package:flutter/material.dart';
import '../auth.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

final _correoRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

// Colores del panel de acceso (igual que la web: siempre oscuro con detalles dorados).
const _fondo = Color(0xFF17110A);
const _campo = Color(0xFF211810);
const _borde = Color(0xFF59431E);
const _label = Color(0xFFD8C69D);
const _texto = Color(0xFFFFF8E8);
const _hint = Color(0xFF8F8067);
const _link = Color(0xFFE0B63F);

InputDecoration _deco(String hint, {Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint),
      filled: true,
      fillColor: _campo,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borde)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borde)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: gold2, width: 1.5)),
    );

Widget _lab(String t) => Padding(padding: const EdgeInsets.only(bottom: 6, top: 14), child: Text(t, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _label)));

/// Panel dorado con el logo + tarjeta oscura del formulario (mismo texto que AuthLayout de la web).
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.titulo, required this.subtitulo, required this.child, required this.pie});
  final String titulo, subtitulo;
  final Widget child, pie;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(gradient: metal),
            padding: EdgeInsets.fromLTRB(28, MediaQuery.of(context).padding.top + 34, 28, 34),
            child: Column(children: [
              Image.asset('assets/logo_dark.png', height: 120),
              const SizedBox(height: 12),
              const Text('Un sistema, toda tu operación', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, height: 1.25, color: Color(0xFF2B1D0B))),
              const SizedBox(height: 8),
              const Text('Donde tu oro y tus materiales polimetálicos cobran forma.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF4A3615))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFF5D76E))),
              const SizedBox(height: 6),
              Text(subtitulo, style: const TextStyle(color: Color(0xFFCDBB94))),
              const SizedBox(height: 8),
              child,
              const SizedBox(height: 18),
              Center(child: pie),
            ]),
          ),
        ]),
      ),
    );
  }
}

Widget _pie(String texto, String link, VoidCallback f) => Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
      Text('$texto ', style: const TextStyle(fontSize: 13.5, color: Color(0xFFA99878))),
      GestureDetector(onTap: f, child: Text(link, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _link))),
    ]);

Widget _btn(String t, VoidCallback f, {bool loading = false}) => SizedBox(width: double.infinity, child: GoldButton(loading ? 'Ingresando...' : t, onTap: f, loading: loading));

// =========================== LOGIN ===========================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.registrado = false, this.correo = ''});
  final bool registrado;
  final String correo;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  late final _correo = TextEditingController(text: widget.correo);
  final _clave = TextEditingController();
  bool _ver = false, _recordar = false, _cargando = false;
  String? _srvCorreo, _srvClave, _general;

  Future<void> _entrar() async {
    setState(() {
      _srvCorreo = _srvClave = _general = null;
    });
    if (!_form.currentState!.validate()) return;
    setState(() => _cargando = true);
    await Future.delayed(const Duration(milliseconds: 500)); // TODO backend: POST /auth/login
    final r = autenticar(_correo.text, _clave.text);
    if (!mounted) return;
    if (!r.ok) {
      setState(() {
        _cargando = false;
        if (r.campo == 'correo') {
          _srvCorreo = r.error;
        } else if (r.campo == 'clave') {
          _srvClave = r.error;
        } else {
          _general = r.error;
        }
      });
      _form.currentState!.validate();
      return;
    }
    sesion = r.usuario;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      titulo: 'Inicia sesión',
      subtitulo: 'Ingresa tus credenciales para entrar al panel',
      pie: _pie('¿No tienes cuenta?', 'Regístrate', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistroScreen()))),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.registrado)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: const Color(0x201FA971), borderRadius: BorderRadius.circular(10)),
              child: const Text('¡Cuenta creada! Ahora inicia sesión con tu correo y contraseña.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1FA971))),
            ),
          _lab('Correo electrónico'),
          TextFormField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: _texto),
            decoration: _deco('tucorreo@gmail.com'),
            onChanged: (_) => _srvCorreo = null,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu correo' : (!_correoRe.hasMatch(v.trim()) ? 'El correo no es válido' : _srvCorreo),
          ),
          _lab('Contraseña'),
          TextFormField(
            controller: _clave,
            obscureText: !_ver,
            style: const TextStyle(color: _texto),
            decoration: _deco('••••••••', suffix: IconButton(tooltip: _ver ? 'Ocultar contraseña' : 'Mostrar contraseña', icon: Icon(_ver ? Icons.visibility : Icons.visibility_off, color: _hint), onPressed: () => setState(() => _ver = !_ver))),
            onChanged: (_) => _srvClave = null,
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : _srvClave,
          ),
          const SizedBox(height: 6),
          Row(children: [
            Checkbox(
              value: _recordar,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return const Color(0xFFD4A72C);
                return null;
              }),
              onChanged: (v) => setState(() => _recordar = v ?? false),
            ),
            const Text('Recordarme', style: TextStyle(fontSize: 13, color: Color(0xFFB9A681))),
            const Spacer(),
            const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 12.5, color: _link)),
          ]),
          if (_general != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_general!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE5484D)))),
          _btn('Iniciar sesión', _entrar, loading: _cargando),
        ]),
      ),
    );
  }
}

// =========================== REGISTRO ===========================
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController(), _correo = TextEditingController(), _tel = TextEditingController();
  final _clave = TextEditingController(), _clave2 = TextEditingController();
  bool _ver = false, _ver2 = false, _terminos = false, _errTerminos = false;
  String? _srvCorreo;

  void _crear() {
    setState(() {
      _srvCorreo = null;
      _errTerminos = !_terminos;
    });
    final ok = _form.currentState!.validate();
    if (!ok || !_terminos) return;
    final r = registrarUsuario(_nombre.text, _correo.text, _tel.text, _clave.text); // TODO backend: POST /auth/registro
    if (!r.ok) {
      setState(() => _srvCorreo = r.error);
      _form.currentState!.validate();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen(registrado: true, correo: _correo.text.trim())), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    Widget eye(bool v, VoidCallback f) => IconButton(tooltip: v ? 'Ocultar contraseña' : 'Mostrar contraseña', icon: Icon(v ? Icons.visibility : Icons.visibility_off, color: _hint), onPressed: f);
    return AuthShell(
      titulo: 'Crea tu cuenta',
      subtitulo: 'Regístrate y lleva el control de toda tu operación.',
      pie: _pie('¿Ya tienes cuenta?', 'Inicia sesión', () => Navigator.of(context).pop()),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lab('Nombre completo'),
          TextFormField(controller: _nombre, style: const TextStyle(color: _texto), decoration: _deco('Ana María Gómez'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe tu nombre completo' : null),
          _lab('Correo electrónico'),
          TextFormField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: _texto),
            decoration: _deco('tucorreo@empresa.com'),
            onChanged: (_) => _srvCorreo = null,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu correo' : (!_correoRe.hasMatch(v.trim()) ? 'El correo no es válido' : _srvCorreo),
          ),
          _lab('Teléfono'),
          TextFormField(
            controller: _tel,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: _texto),
            decoration: _deco('3001234567'),
            validator: (v) => RegExp(r'^\d{7,15}$').hasMatch((v ?? '').trim()) ? null : 'Solo números, entre 7 y 15 dígitos',
          ),
          _lab('Contraseña'),
          TextFormField(
            controller: _clave,
            obscureText: !_ver,
            style: const TextStyle(color: _texto),
            decoration: _deco('Mínimo 8 caracteres', suffix: eye(_ver, () => setState(() => _ver = !_ver))),
            validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
          ),
          _lab('Confirmar contraseña'),
          TextFormField(
            controller: _clave2,
            obscureText: !_ver2,
            style: const TextStyle(color: _texto),
            decoration: _deco('Repite la contraseña', suffix: eye(_ver2, () => setState(() => _ver2 = !_ver2))),
            validator: (v) => v != _clave.text ? 'Las contraseñas no coinciden' : null,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _terminos = !_terminos),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Checkbox(
                value: _terminos,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return const Color(0xFFD4A72C);
                  return null;
                }),
                onChanged: (v) => setState(() => _terminos = v ?? false),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text.rich(TextSpan(style: TextStyle(fontSize: 13, color: Color(0xFFB9A681)), children: [
                    TextSpan(text: 'Acepto los '),
                    TextSpan(text: 'términos y condiciones', style: TextStyle(color: _link, fontWeight: FontWeight.w600)),
                  ])),
                ),
              ),
            ]),
          ),
          if (_errTerminos && !_terminos) const Padding(padding: EdgeInsets.only(left: 12, bottom: 8), child: Text('Debes aceptar los términos y condiciones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE5484D)))),
          const SizedBox(height: 6),
          _btn('Crear cuenta', _crear),
        ]),
      ),
    );
  }
}
