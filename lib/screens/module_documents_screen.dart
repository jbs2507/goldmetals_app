import 'package:flutter/material.dart';
import '../core/pick_file.dart';
import '../models/module_config.dart';
import '../theme.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';

String _slugDoc(String s) {
  var base = s.toLowerCase().trim();
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñ';
  const to = 'aaaaaeeeeiiiiooooouuuun';
  for (var i = 0; i < from.length; i++) {
    base = base.replaceAll(from[i], to[i]);
  }
  base = base.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  return base.isEmpty ? 'documento' : base;
}

/// Submenú de documentos de un registro: lista los campos marcados como
/// `doc: true` en el ModuleCfg (por ejemplo, los documentos que hay que
/// cargarle a una venta) y permite adjuntar/quitar cada uno por separado,
/// en un espacio propio en vez de mezclarlos con el resto del formulario.
class ModuleDocumentsScreen extends StatefulWidget {
  const ModuleDocumentsScreen({super.key, required this.cfg, required this.item});
  final ModuleCfg cfg;
  final Rec item;
  @override
  State<ModuleDocumentsScreen> createState() => _ModuleDocumentsScreenState();
}

class _ModuleDocumentsScreenState extends State<ModuleDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final cfg = widget.cfg, m = widget.item;
    final docs = cfg.docFields;
    final adjuntos = docs.where((f) => '${m[f.key] ?? ''}'.isNotEmpty).length;
    return Scaffold(
      backgroundColor: p.bg,
      appBar: GoldAppBar('Documentos · ${cfg.titleOf(m)}'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          GmCard(
            child: Row(children: [
              Icon(Icons.folder_open_outlined, color: gold3),
              const SizedBox(width: 10),
              Expanded(child: Text('$adjuntos de ${docs.length} documentos adjuntos', style: TextStyle(fontWeight: FontWeight.w700, color: p.tx))),
            ]),
          ),
          for (final f in docs) _docTile(f, p, m),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: gold2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: Icon(Icons.add, color: gold3),
            label: Text('Agregar nuevo documento', style: TextStyle(color: gold3, fontWeight: FontWeight.w700)),
            onPressed: _agregarDocumento,
          ),
        ],
      ),
    );
  }

  // Igual que con los países: se pide el nombre y el documento queda
  // disponible de una vez en la lista, listo para adjuntarle un PDF.
  Future<void> _agregarDocumento() async {
    final ctl = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar documento'),
        content: TextField(controller: ctl, autofocus: true, decoration: const InputDecoration(hintText: 'Nombre del documento')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()), child: const Text('Agregar')),
        ],
      ),
    );
    if (nombre == null || nombre.isEmpty) return;
    final key = 'doc_${_slugDoc(nombre)}_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      widget.cfg.fields.add(Fld(key, nombre, type: FT.file, doc: true, accept: 'pdf'));
      widget.item[key] = '';
    });
  }

  Future<void> _toggleAdjunto(Fld f, bool has) async {
    if (has) {
      setState(() => widget.item[f.key] = '');
      return;
    }
    final ruta = await pickPdf(context);
    if (ruta != null && mounted) setState(() => widget.item[f.key] = ruta);
  }

  Widget _docTile(Fld f, Pal p, Rec m) {
    final has = '${m[f.key] ?? ''}'.isNotEmpty;
    return GmCard(
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: has ? goldSoft : p.card, shape: BoxShape.circle, border: Border.all(color: has ? gold2 : p.ln)),
          child: Icon(has ? Icons.check : Icons.insert_drive_file_outlined, color: has ? gold3 : p.mu, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f.label, style: TextStyle(fontWeight: FontWeight.w700, color: p.tx)),
            Text(has ? 'Adjunto' : 'Sin adjuntar', style: TextStyle(fontSize: 12, color: has ? gold3 : p.mu)),
          ]),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(side: BorderSide(color: has ? gold2 : p.ln), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          icon: Icon(has ? Icons.close : Icons.attach_file, size: 16, color: has ? const Color(0xFFE5484D) : gold3),
          onPressed: () => _toggleAdjunto(f, has),
          label: Text(has ? 'Quitar' : 'Adjuntar', style: TextStyle(color: has ? const Color(0xFFE5484D) : p.tx)),
        ),
      ]),
    );
  }
}
