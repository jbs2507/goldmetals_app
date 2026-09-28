import 'package:flutter/material.dart';
import '../modules/modules.dart';
import '../screens/insumos_screen.dart';
import '../screens/module_list_screen.dart';
import '../theme.dart';

final List<({String label, List<({String label, String key})> items})> menuWeb = const [
  (
    label: 'COMPRAS',
    items: [
      (label: 'Proveedores', key: 'proveedores'),
      (label: 'Insumos', key: 'insumos'),
    ],
  ),
  (
    label: 'VENTAS',
    items: [
      (label: 'Clientes', key: 'clientes'),
      (label: 'Pedidos', key: 'pedidos'),
    ],
  ),
  (
    label: 'OPERACIÓN',
    items: [
      (label: 'Producción', key: 'produccion'),
      (label: 'Empleados', key: 'empleados'),
    ],
  ),
  (
    label: 'CONFIGURACIÓN',
    items: [
      (label: 'Usuarios', key: 'usuarios'),
    ],
  ),
];

/// Menú lateral: mismo orden, secciones y nombres que el Sidebar de la web.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.active = ''});
  final String active; // '' = Dashboard, o la key del módulo

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    Widget item(String label, bool on, VoidCallback f) => GestureDetector(
          onTap: f,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: on
                ? BoxDecoration(
                    gradient: p.dark ? metal : p.navActive,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: p.dark ? const Color(0x55000000) : const Color(0x33E6B53A), blurRadius: 14, offset: const Offset(0, 6))])
                : null,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: on ? (p.dark ? ink : brown) : p.sideText)),
          ),
        );
    Widget section(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 5),
          child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: p.sideText.withAlpha(165))),
        );

    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(gradient: p.side),
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.only(bottom: 20), children: [
            Padding(padding: const EdgeInsets.fromLTRB(40, 14, 40, 8), child: Image.asset(p.logo, height: 90)),
            section('PRINCIPAL'),
            item('Dashboard', active.isEmpty, () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((r) => r.isFirst);
            }),
            for (final group in menuWeb) ...[
              section(group.label),
              for (final itemData in group.items)
                item(itemData.label, active == itemData.key, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => itemData.key == 'insumos' ? const InsumosScreen() : ModuleListScreen(cfg: moduleByKey(itemData.key))),
                    (r) => r.isFirst,
                  );
                }),
            ],
          ]),
        ),
      ),
    );
  }
}
