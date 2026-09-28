import 'package:flutter/material.dart';
import '../models/module_config.dart';
import '../theme.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'module_documents_screen.dart';

/// Detalle genérico de un registro (Consultar).
class ModuleDetailScreen extends StatefulWidget {
  const ModuleDetailScreen({super.key, required this.cfg, required this.item});
  final ModuleCfg cfg;
  final Rec item;
  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final cfg = widget.cfg, m = widget.item;
    final est = '${m['estado'] ?? ''}';
    return Scaffold(
      backgroundColor: p.bg,
      appBar: GoldAppBar('Consultar ${cfg.singular}'),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        GmCard(
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: metal, borderRadius: BorderRadius.circular(14)), child: Icon(cfg.icon, color: ink)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cfg.titleOf(m), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: p.tx)),
                Text(cfg.subOf(m), style: TextStyle(color: p.mu)),
              ]),
            ),
            if (est.isNotEmpty) StatusBadge(est, cfg.labelOf('estado', est)),
          ]),
        ),
        GmCard(
          child: Column(children: [
            for (final f in cfg.fields.where((f) => f.type != FT.password && !f.doc && f.visible(m)))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.ln))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 4, child: Text(f.label, style: TextStyle(color: p.mu, fontSize: 13))),
                  Expanded(flex: 5, child: Text(cfg.labelOf(f.key, m[f.key]), textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, color: p.tx))),
                ]),
              ),
          ]),
        ),
        if (cfg.hasDocs) ...[
          const SizedBox(height: 4),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ModuleDocumentsScreen(cfg: cfg, item: m)));
              if (mounted) setState(() {});
            },
            child: GmCard(
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: goldSoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.folder_outlined, color: gold3)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Documentos', style: TextStyle(fontWeight: FontWeight.w800, color: p.tx)),
                    Text('${cfg.docFields.where((f) => '${m[f.key] ?? ''}'.isNotEmpty).length} de ${cfg.docFields.length} adjuntos', style: TextStyle(fontSize: 12, color: p.mu)),
                  ]),
                ),
                Icon(Icons.chevron_right, color: p.mu),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: gold2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Volver', style: TextStyle(color: p.tx, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
