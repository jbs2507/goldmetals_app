import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modules/modules.dart';
import '../theme.dart';
import '../widgets/cards.dart';
import '../auth.dart';
import 'auth.dart';
import 'insumos_screen.dart';
import 'module_list_screen.dart';

/// Pantalla principal: Dashboard + menú lateral (drawer) con todos los módulos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _key = GlobalKey<ScaffoldState>();

  void _open(String k) {
    if (k == 'insumos') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InsumosScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ModuleListScreen(cfg: moduleByKey(k))));
  }

  void _cerrarSesion() {
    sesion = null;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _proximamente() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente disponible')));

  void _abrirNotificaciones(Pal p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Notificaciones', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: p.tx)),
            const SizedBox(height: 14),
            _notif(p, Icons.inventory_2_outlined, 'Stock de oro bajo', 'Quedan 2,840 gr disponibles.'),
            _notif(p, Icons.local_shipping_outlined, 'Pedido próximo a vencer', 'Joyería El Diamante · entrega 15 sep.'),
            _notif(p, Icons.trending_up, 'Buen mes de ventas', 'Vas 13.4% arriba frente al mes anterior.'),
          ]),
        ),
      ),
    );
  }

  Widget _notif(Pal p, IconData icon, String t, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: goldSoft, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: gold3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: TextStyle(fontWeight: FontWeight.w700, color: p.tx)),
              const SizedBox(height: 2),
              Text(s, style: TextStyle(fontSize: 12, color: p.mu)),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final top = MediaQuery.of(context).padding.top;
    final fg = p.onHeader;
    final inicialesTxt = sesion != null ? iniciales(sesion!.nombre) : 'JB';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
      key: _key,
      backgroundColor: p.bg,
      drawer: _AppDrawer(onOpen: (k) {
        Navigator.of(context).pop();
        _open(k);
      }),
      body: Stack(children: [
        Positioned(top: 0, left: 0, right: 0, height: top + 200, child: Container(decoration: BoxDecoration(gradient: p.header))),
        SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 6),
              child: Row(children: [
                Image.asset(p.logoHeader, height: 38),
                const Spacer(),
                IconButton(
                  tooltip: 'Notificaciones',
                  icon: Stack(clipBehavior: Clip.none, children: [
                    Icon(Icons.notifications_outlined, color: fg),
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(color: const Color(0xFFE5484D), shape: BoxShape.circle, border: Border.all(color: p.dark ? const Color(0xFF15100A) : const Color(0xFFF8F7F2), width: 1.5)),
                      ),
                    ),
                  ]),
                  onPressed: () => _abrirNotificaciones(p),
                ),
                IconButton(
                  tooltip: p.dark ? 'Modo claro' : 'Modo oscuro',
                  icon: Icon(p.dark ? Icons.light_mode : Icons.dark_mode, color: fg),
                  onPressed: () => themeMode.value = p.dark ? ThemeMode.light : ThemeMode.dark,
                ),
                PopupMenuButton<String>(
                  tooltip: 'Cuenta',
                  offset: const Offset(0, 44),
                  color: p.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: p.ln)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'perfil',
                      child: Row(children: [Icon(Icons.person_outline, size: 18, color: gold3), const SizedBox(width: 10), Text('Mi perfil', style: TextStyle(color: p.tx))]),
                    ),
                    PopupMenuItem(
                      value: 'config',
                      child: Row(children: [Icon(Icons.settings_outlined, size: 18, color: gold3), const SizedBox(width: 10), Text('Configuración', style: TextStyle(color: p.tx))]),
                    ),
                    PopupMenuItem(
                      value: 'salir',
                      child: Row(children: [const Icon(Icons.logout, size: 18, color: Color(0xFFE5484D)), const SizedBox(width: 10), Text('Cerrar sesión', style: TextStyle(color: p.tx))]),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'salir') {
                      _cerrarSesion();
                    } else {
                      _proximamente();
                    }
                  },
                  child: CircleAvatar(radius: 17, backgroundColor: gold2, child: Text(inicialesTxt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink))),
                ),
              ]),
            ),
            Expanded(
              child: _DashboardBody(nombre: sesion?.nombre ?? 'Usuario'),
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: p.navBg, gradient: p.navGradient),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              _nav(p, Icons.dashboard_rounded, 'Inicio', true, () {}),
              _nav(p, Icons.trending_up, 'Ventas', false, () => _open('ventas')),
              _nav(p, Icons.shopping_cart_outlined, 'Compras', false, () => _open('compras')),
              _nav(p, Icons.menu, 'Menú', false, () => _key.currentState?.openDrawer()),
            ]),
          ),
        ),
      ),
    ),
    );
  }

  Widget _nav(Pal p, IconData i, String t, bool on, VoidCallback f) {
    final c = on ? p.navOn : p.navOff;
    return Expanded(
      child: InkWell(
        onTap: f,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: BoxDecoration(gradient: on && !p.dark ? p.navActive : null, borderRadius: BorderRadius.circular(99)),
            child: Icon(i, color: c),
          ),
          Text(t, style: TextStyle(fontSize: 11, fontWeight: on ? FontWeight.w700 : FontWeight.normal, color: c)),
        ]),
      ),
    );
  }
}

/// Saludo según la hora del día (Buenos días / Buenas tardes / Buenas noches).
String _saludoHora() {
  final h = DateTime.now().hour;
  if (h >= 5 && h < 12) return 'Buenos días';
  if (h >= 12 && h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.nombre});
  final String nombre;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text('${_saludoHora()}, $nombre', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.dark ? p.onHeader : ink)),
        ),
        const KpiCards(),
        const ChartCard(),
        const DistCard(),
        const OrdersCard(),
        const ProductionCard(),
        const PricesCard(),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.onOpen});
  final void Function(String key) onOpen;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    const groups = {
      'CONFIGURACIÓN': ['usuarios'],
      'COMPRAS': ['proveedores'],
      'OPERACIÓN': ['produccion', 'empleados'],
      'INSUMOS': ['insumos'],
      'VENTAS': ['clientes', 'pedidos'],
    };
    String label(String k) => k == 'insumos' ? 'Insumos' : moduleByKey(k).title;
    IconData icon(String k) => k == 'insumos' ? Icons.diamond_outlined : moduleByKey(k).icon;
    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: Colors.transparent,
      child: Container(
       decoration: BoxDecoration(color: p.drawerBg, gradient: p.dark ? null : p.side),
       child: Column(children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: p.dark ? p.header : null),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 18),
          child: Align(alignment: Alignment.centerLeft, child: Image.asset(p.logo, height: 56)),
        ),
        Expanded(
          child: Material(type: MaterialType.transparency, child: ListView(padding: const EdgeInsets.symmetric(vertical: 6), children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(gradient: p.dark ? null : p.navActive, borderRadius: BorderRadius.circular(12)),
              child: ListTile(leading: Icon(Icons.dashboard_rounded, color: p.dark ? gold2 : brown), title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w800, color: p.dark ? p.drawerTx : brown)), onTap: () => Navigator.of(context).pop()),
            ),
            for (final g in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Text(g.key, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.drawerMu)),
              ),
              for (final k in g.value)
                ListTile(
                  dense: true,
                  leading: Icon(icon(k), color: p.drawerIcon),
                  title: Text(label(k), style: TextStyle(fontWeight: FontWeight.w600, color: p.drawerTx)),
                  onTap: () => onOpen(k),
                ),
            ],
          ])),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
      ]),
      ),
    );
  }
}
