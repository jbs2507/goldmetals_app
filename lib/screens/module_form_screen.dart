import '../core/pick_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/module_config.dart';
import '../theme.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
// Solo letras (con tildes y ñ), espacios y puntuación básica de nombres/razón social.
final _lettersRe = RegExp(r"^[A-Za-zÀ-ÿñÑ\s.,&'-]+$");
final _lettersAllow = RegExp(r"[A-Za-zÀ-ÿñÑ\s.,&'-]");
// Solo dígitos (se permite el guion de documentos con dígito de verificación, ej. NIT).
final _digitsRe = RegExp(r'^[0-9-]+$');
final _digitsAllow = RegExp(r'[0-9-]');

DateTime _hoy() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String _slug(String s) {
  var base = s.toLowerCase().trim();
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñ';
  const to = 'aaaaaeeeeiiiiooooouuuun';
  for (var i = 0; i < from.length; i++) {
    base = base.replaceAll(from[i], to[i]);
  }
  base = base.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  return base.isEmpty ? 'documento' : base;
}

/// Formulario genérico para Registrar / Editar, construido desde ModuleCfg.
class ModuleFormScreen extends StatefulWidget {
  const ModuleFormScreen({super.key, required this.cfg, this.item});
  final ModuleCfg cfg;
  final Rec? item; // null = registrar
  @override
  State<ModuleFormScreen> createState() => _ModuleFormScreenState();
}

class _ModuleFormScreenState extends State<ModuleFormScreen> {
  final _form = GlobalKey<FormState>();
  final Rec v = {};
  final Map<String, TextEditingController> _dates = {};
  bool _showPass = false;

  ModuleCfg get cfg => widget.cfg;
  bool get edit => widget.item != null;

  @override
  void initState() {
    super.initState();
    v.addAll(widget.item ?? {});
    for (final f in cfg.fields) {
      if (f.type == FT.check) {
        v[f.key] = v[f.key] == true;
      } else if (v[f.key] == null) {
        v[f.key] = f.def ?? '';
      }
    }
  }

  TextEditingController _dateCtl(Fld f) => _dates.putIfAbsent(f.key, () => TextEditingController(text: '${v[f.key]}'));

  String? _validate(Fld f, String? x) {
    final txt = (x ?? '').trim();
    final required = f.req && (!f.onlyCreate || !edit);
    if (required && txt.isEmpty) return 'Campo obligatorio';
    if (f.type == FT.number && txt.isNotEmpty) {
      final n = num.tryParse(txt);
      if (n == null) return 'Número no válido';
      if (required && n <= 0) return 'Debe ser mayor a 0';
    }
    if (f.type == FT.email && txt.isNotEmpty && !_emailRe.hasMatch(txt)) return 'Correo no válido';
    if (f.lettersOnly && txt.isNotEmpty && !_lettersRe.hasMatch(txt)) return 'Solo se permiten letras';
    if (f.digitsOnly && txt.isNotEmpty && !_digitsRe.hasMatch(txt)) return 'Solo se permiten números';
    if (f.type == FT.date && txt.isNotEmpty) {
      final d = DateTime.tryParse(txt);
      if (d != null && d.isBefore(_hoy())) return 'La fecha no puede ser anterior a hoy';
    }
    return null;
  }

  Widget _field(Fld f, Pal p) {
    final label = f.label + ((f.req && (!f.onlyCreate || !edit)) ? ' *' : '');
    switch (f.type) {
      case FT.select:
        const addKey = '__agregar_nuevo__';
        final cur = '${v[f.key]}';
        return DropdownButtonFormField<String>(
          initialValue: f.opts.any((o) => o.v == cur) ? cur : null,
          isExpanded: true,
          dropdownColor: p.card,
          decoration: InputDecoration(labelText: label),
          hint: const Text('Seleccionar'),
          items: [
            for (final o in f.opts) DropdownMenuItem(value: o.v, child: Text(o.l, overflow: TextOverflow.ellipsis)),
            if (f.allowAdd)
              DropdownMenuItem(
                value: addKey,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, size: 16, color: gold3),
                  const SizedBox(width: 6),
                  Text('Agregar nuevo', style: TextStyle(color: gold3, fontWeight: FontWeight.w700)),
                ]),
              ),
          ],
          onChanged: (x) async {
            if (x == addKey) {
              final nuevo = await _promptNuevoValor(f.label);
              if (nuevo != null && nuevo.isNotEmpty) {
                setState(() {
                  if (!f.opts.any((o) => o.v.toLowerCase() == nuevo.toLowerCase())) f.opts.add(Opt(nuevo));
                  v[f.key] = nuevo;
                });
              }
              return;
            }
            setState(() => v[f.key] = x ?? '');
          },
          validator: (x) => _validate(f, x),
        );
      case FT.check:
        return SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
          activeThumbColor: gold2,
          activeTrackColor: gold2.withAlpha(179),
          title: Text(f.label, style: TextStyle(color: p.tx)),
          value: v[f.key] == true,
          onChanged: (x) => setState(() => v[f.key] = x),
        );
      case FT.file:
        return FormField<String>(
          initialValue: '${v[f.key]}',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_) => _validate(f, '${v[f.key]}'),
          builder: (state) {
            final has = '${v[f.key]}'.isNotEmpty;
            final esFoto = f.accept == 'image';
            final err = state.errorText;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: err != null ? Theme.of(context).colorScheme.error : (has ? gold2 : p.ln)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(has ? Icons.check_circle : (esFoto ? Icons.photo_outlined : Icons.attach_file), color: gold3),
                  label: Align(alignment: Alignment.centerLeft, child: Text(has ? '${f.label}: adjunto' : 'Adjuntar ${f.label}', style: TextStyle(color: p.tx))),
                  onPressed: () async {
                    await _pickFile(f, has);
                    state.didChange('${v[f.key]}');
                  },
                ),
                if (err != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(err, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                  ),
              ],
            );
          },
        );
      case FT.date:
        final c = _dateCtl(f);
        return TextFormField(
          controller: c,
          readOnly: true,
          decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
          onTap: () async {
            final hoy = _hoy();
            DateTime inicial = hoy;
            // Atajo: si es la fecha de entrega y ya hay una fecha base, se sugiere 1 mes después.
            if (f.key == 'fecha_entrega') {
              final base = DateTime.tryParse('${v['fecha']}'.split('/').reversed.join('-'));
              if (base != null) {
                final sugerida = DateTime(base.year, base.month + 1, base.day);
                inicial = sugerida.isBefore(hoy) ? hoy : sugerida;
              }
            } else {
              final actual = DateTime.tryParse('${v[f.key]}');
              if (actual != null && !actual.isBefore(hoy)) inicial = actual;
            }
            // No se puede escoger un día anterior al de hoy.
            final d = await showDatePicker(context: context, initialDate: inicial, firstDate: hoy, lastDate: DateTime(2100));
            if (d != null) {
              final s = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              setState(() {
                c.text = s;
                v[f.key] = s;
              });
            }
          },
          validator: (x) => _validate(f, x),
        );
      default:
        return TextFormField(
          initialValue: '${v[f.key]}',
          obscureText: f.type == FT.password && !_showPass,
          keyboardType: f.type == FT.number
              ? const TextInputType.numberWithOptions(decimal: true)
              : (f.type == FT.email
                  ? TextInputType.emailAddress
                  : (f.digitsOnly ? TextInputType.number : TextInputType.text)),
          inputFormatters: [
            if (f.lettersOnly) FilteringTextInputFormatter.allow(_lettersAllow),
            if (f.digitsOnly) FilteringTextInputFormatter.allow(_digitsAllow),
          ],
          decoration: InputDecoration(
            labelText: label,
            hintText: (f.type == FT.password && edit) ? 'Dejar vacío para no cambiarla' : null,
            suffixIcon: f.type == FT.password ? IconButton(icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off, color: p.mu), onPressed: () => setState(() => _showPass = !_showPass)) : null,
          ),
          onChanged: (x) => v[f.key] = x,
          validator: (x) => _validate(f, x),
        );
    }
  }

  // Si ya había un archivo adjunto, el botón lo quita. Si no, abre directamente
  // la biblioteca/explorador del dispositivo, restringido al tipo permitido.
  Future<void> _pickFile(Fld f, bool has) async {
    if (has) {
      setState(() => v[f.key] = '');
      return;
    }
    try {
      if (f.accept == 'image') {
        final XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (img != null) setState(() => v[f.key] = img.path);
      } else if (f.accept == 'pdf') {
        final ruta = await pickPdf(context);
        if (ruta != null && mounted) setState(() => v[f.key] = ruta);
      } else {
        // Campos de archivo sin restricción definida: se mantiene el marcador de posición original.
        setState(() => v[f.key] = 'documento_adjunto');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir la galería. $e')));
      }
    }
  }

  Future<String?> _promptNuevoValor(String campo) {
    final ctl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar $campo'),
        content: TextField(controller: ctl, autofocus: true, decoration: const InputDecoration(hintText: 'Escribe el nuevo valor')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()), child: const Text('Agregar')),
        ],
      ),
    );
  }

  // Agrega un nuevo campo de documento (PDF) al módulo, igual que se hace con
  // los países: se pide el nombre y queda disponible de una vez en el formulario.
  Future<void> _agregarDocumento() async {
    final nombre = await _promptNuevoValor('documento');
    if (nombre == null || nombre.isEmpty) return;
    final key = 'doc_${_slug(nombre)}_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      cfg.fields.add(Fld(key, nombre, type: FT.file, accept: 'pdf'));
      v[key] = '';
    });
  }

  void _save() {
    if (!_form.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete los campos obligatorios.')));
      return;
    }
    final out = Rec.of(v);
    for (final f in cfg.fields) {
      if (f.type == FT.number) out[f.key] = num.tryParse('${out[f.key]}'.trim()) ?? out[f.key];
    }
    if (edit) {
      widget.item!
        ..clear()
        ..addAll(out);
    } else {
      out[cfg.idKey] = cfg.nextId();
      cfg.data.add(out); // TODO: enviar al backend
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      appBar: GoldAppBar('${edit ? 'Editar' : 'Registrar'} ${cfg.singular}'),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(14), children: [
          GmCard(
            child: Column(children: [
              for (final f in cfg.fields.where((f) => (edit || f.key != 'estado') && !f.doc && f.visible(v)))
                Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: _field(f, p)),
            ]),
          ),
          if (cfg.fields.any((f) => f.accept == 'pdf' && !f.doc))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: gold2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: Icon(Icons.add, color: gold3),
                label: Text('Agregar nuevo documento', style: TextStyle(color: gold3, fontWeight: FontWeight.w700)),
                onPressed: _agregarDocumento,
              ),
            ),
          if (cfg.fields.any((f) => f.showIf != null && !f.visible(v)))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: p.mu),
                const SizedBox(width: 6),
                Expanded(child: Text('Algunos campos se habilitan cuando se marquen las condiciones requeridas (pago y producción).', style: TextStyle(fontSize: 12, color: p.mu))),
              ]),
            ),
          const SizedBox(height: 16),
          GoldButton(edit ? 'Guardar cambios' : 'Guardar', icon: Icons.save_outlined, onTap: _save),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: gold2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: p.tx, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
