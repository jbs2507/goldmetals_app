import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// AppBar (blanco hueso en modo claro, igual que el header del dashboard).
class GoldAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GoldAppBar(this.title, {super.key, this.actions});
  final String title;
  final List<Widget>? actions;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final fg = p.onHeader;
    return AppBar(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: fg, fontSize: 18)),
      iconTheme: IconThemeData(color: fg),
      actions: actions,
      systemOverlayStyle: p.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(decoration: BoxDecoration(gradient: p.header)),
    );
  }
}

/// Botón principal dorado metálico.
class GoldButton extends StatelessWidget {
  const GoldButton(this.label, {super.key, required this.onTap, this.loading = false, this.icon});
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: loading ? null : onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: gold2,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0x44A8730F), blurRadius: 12, offset: Offset(0, 5))],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ink))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      if (icon != null) ...[Icon(icon, size: 18, color: ink), const SizedBox(width: 8)],
                      Text(label, style: const TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 15)),
                    ]),
            ),
          ),
        ),
      );
}

/// Etiqueta de estado (Activo, Cancelada, etc.).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.value, this.label, {super.key});
  final String value, label;
  @override
  Widget build(BuildContext context) {
    final bad = ['INACTIVO', 'CANCELADA', 'CANCELADO'].contains(value);
    final mid = ['EN_PRODUCCION', 'DESPACHADA', 'LISTO'].contains(value);
    final bg = bad ? const Color(0x22E5484D) : (mid ? const Color(0x33A8730F) : goldSoft);
    final fg = bad ? const Color(0xFFE5484D) : (mid ? gold3 : const Color(0xFFB98010));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
