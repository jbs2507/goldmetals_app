import 'package:flutter/material.dart';
import '../modules/modules.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'module_list_screen.dart';

/// Insumos: un único módulo en el menú. El buscador va arriba (igual que en
/// los demás módulos) y justo debajo un submenú (mismos chips que los
/// filtros) para cambiar entre "Insumos de oro" e "Insumos polimetálicos",
/// que tienen tablas y campos distintos.
class InsumosScreen extends StatefulWidget {
  const InsumosScreen({super.key});
  @override
  State<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends State<InsumosScreen> {
  String _tipo = 'insumosOro';

  Widget _tabs(Pal p) => SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          children: [
            for (final k in const ['insumosOro', 'insumosPolimetalicos'])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ChoiceChip(
                  label: Text(moduleByKey(k).title, style: TextStyle(fontWeight: FontWeight.w700, color: _tipo == k ? ink : p.tx)),
                  selected: _tipo == k,
                  selectedColor: gold2,
                  backgroundColor: p.card,
                  side: BorderSide(color: p.ln),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _tipo = k),
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: GoldAppBar('Insumos'),
      body: ModuleListScreen(key: ValueKey(_tipo), cfg: moduleByKey(_tipo), embedded: true, topSlot: _tabs(p)),
    );
  }
}
