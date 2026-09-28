import 'package:flutter/material.dart';
import '../models/module_config.dart';
import '../theme.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'module_detail_screen.dart';
import 'module_documents_screen.dart';
import 'module_form_screen.dart';

/// Lista genérica con búsqueda, filtro por estado, ver, editar y activar/inactivar.
/// Si `cfg.hasDocs` es true (ej. Ventas), muestra además un submenú "Documentos"
/// justo encima de los filtros de estado, para ir directo a los documentos de cada registro.
/// `embedded` = true la usa otra pantalla (ej. Insumos) sin su propio Scaffold/AppBar.
class ModuleListScreen extends StatefulWidget {
  const ModuleListScreen({super.key, required this.cfg, this.embedded = false, this.topSlot});
  final ModuleCfg cfg;
  final bool embedded;
  final Widget? topSlot; // se dibuja debajo del buscador y encima de los demás filtros (ej. submenú Oro/Polimetálicos)
  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  String _q = '';
  String _estado = 'TODOS';
  bool _docs = false; // submenú: false = Ventas, true = Documentos

  ModuleCfg get cfg => widget.cfg;

  List<Rec> get _items => cfg.data.where((m) {
        final okQ = _q.isEmpty || cfg.searchKeys.any((k) => '${m[k] ?? ''}'.toLowerCase().contains(_q.toLowerCase()));
        final okE = _docs || _estado == 'TODOS' || m['estado'] == _estado;
        return okQ && okE;
      }).toList();

  Future<void> _go(Widget w, {String? msg}) async {
    final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => w));
    if (!mounted) return;
    setState(() {});
    if (ok == true && msg != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final body = _body(context, p);
    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: GoldAppBar(cfg.title),
      floatingActionButton: (cfg.canCreate && !_docs)
          ? FloatingActionButton.extended(
              backgroundColor: gold2,
              foregroundColor: ink,
              icon: const Icon(Icons.add),
              label: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () => _go(ModuleFormScreen(cfg: cfg), msg: 'Registro guardado'),
            )
          : null,
      body: body,
    );
  }

  Widget _body(BuildContext context, Pal p) {
    final items = _items;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(hintText: 'Buscar en ${cfg.title.toLowerCase()}…', prefixIcon: Icon(Icons.search, color: p.mu)),
        ),
      ),
      if (widget.topSlot != null) widget.topSlot!,
      // Submenú "Documentos": mismo estilo de chips que los filtros de estado.
      if (cfg.hasDocs)
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final t in [(v: false, l: cfg.title), (v: true, l: 'Documentos')])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                  child: ChoiceChip(
                    label: Text(t.l, style: TextStyle(fontWeight: FontWeight.w700, color: _docs == t.v ? ink : p.tx)),
                    avatar: t.v ? Icon(Icons.folder_outlined, size: 16, color: _docs == t.v ? ink : gold3) : null,
                    selected: _docs == t.v,
                    selectedColor: gold2,
                    backgroundColor: p.card,
                    side: BorderSide(color: p.ln),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _docs = t.v),
                  ),
                ),
            ],
          ),
        ),
      if (!_docs && cfg.filters.isNotEmpty)
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final o in [const Opt('TODOS', 'Todos'), ...cfg.filters])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                  child: ChoiceChip(
                    label: Text(o.l, style: TextStyle(fontWeight: FontWeight.w700, color: _estado == o.v ? ink : p.tx)),
                    selected: _estado == o.v,
                    selectedColor: gold2,
                    backgroundColor: p.card,
                    side: BorderSide(color: p.ln),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _estado = o.v),
                  ),
                ),
            ],
          ),
        ),
      Expanded(
        child: items.isEmpty
            ? Center(child: Text('No hay resultados', style: TextStyle(color: p.mu)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
                itemCount: items.length,
                itemBuilder: (_, i) => _docs ? _docTile(items[i], p) : _tile(items[i], p),
              ),
      ),
    ]);
  }

  Widget _tile(Rec m, Pal p) {
    final est = '${m['estado'] ?? ''}';
    final extra = cfg.extraOf(m);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _go(ModuleDetailScreen(cfg: cfg, item: m)),
      child: GmCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(gradient: metal, borderRadius: BorderRadius.circular(12)),
              child: Icon(cfg.icon, color: ink, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cfg.titleOf(m), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: p.tx)),
                const SizedBox(height: 2),
                Text(cfg.subOf(m), style: TextStyle(fontSize: 13, color: p.mu)),
                if (extra.isNotEmpty) Text(extra, style: TextStyle(fontSize: 12, color: p.mu)),
              ]),
            ),
            if (est.isNotEmpty) StatusBadge(est, cfg.labelOf('estado', est)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(tooltip: 'Consultar', icon: const Icon(Icons.visibility_outlined, color: gold3), onPressed: () => _go(ModuleDetailScreen(cfg: cfg, item: m))),
            IconButton(tooltip: 'Editar', icon: const Icon(Icons.edit_outlined, color: gold3), onPressed: () => _go(ModuleFormScreen(cfg: cfg, item: m), msg: 'Cambios guardados')),
          ]),
        ]),
      ),
    );
  }

  /// Fila del submenú "Documentos": estado de adjuntos de cada registro, entra directo a esos documentos.
  Widget _docTile(Rec m, Pal p) {
    final docs = cfg.docFields;
    final n = docs.where((f) => '${m[f.key] ?? ''}'.isNotEmpty).length;
    final completo = docs.isNotEmpty && n == docs.length;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _go(ModuleDocumentsScreen(cfg: cfg, item: m)),
      child: GmCard(
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: completo ? goldSoft : p.card, shape: BoxShape.circle, border: Border.all(color: completo ? gold2 : p.ln)),
            child: Icon(completo ? Icons.check : Icons.folder_outlined, color: completo ? gold3 : p.mu, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cfg.titleOf(m), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: p.tx)),
              const SizedBox(height: 2),
              Text('$n de ${docs.length} documentos adjuntos', style: TextStyle(fontSize: 13, color: p.mu)),
            ]),
          ),
          Icon(Icons.chevron_right, color: p.mu),
        ]),
      ),
    );
  }
}
