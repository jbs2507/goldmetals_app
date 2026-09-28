import 'package:flutter/material.dart';

typedef Rec = Map<String, Object?>;

/// Tipos de campo que soportan los formularios genéricos.
enum FT { text, number, date, select, email, password, check, file }

class Opt {
  final String v, l;
  const Opt(this.v, [String? label]) : l = label ?? v;
}

class Fld {
  final String key, label;
  final FT type;
  final List<Opt> opts;
  final bool req; // obligatorio
  final bool onlyCreate; // obligatorio solo al registrar (ej. contraseña)
  final Object? def;
  final bool Function(Rec)? showIf; // si no es null, el campo solo se muestra/edita cuando esto es true
  final bool doc; // true = documento que se gestiona desde el submenú "Documentos" (no aparece en el formulario/detalle principal)
  final bool allowAdd; // solo FT.select: permite escribir y agregar una opción nueva a la lista
  final String? accept; // solo FT.file: 'pdf' o 'image'. Restringe el tipo y abre la biblioteca/explorador directamente
  final bool lettersOnly; // solo FT.text: solo letras/espacios/puntuación de nombres, nada de números ni caracteres raros
  final bool digitsOnly; // solo FT.text: solo dígitos (y guion, para documentos con dígito de verificación)
  const Fld(this.key, this.label,
      {this.type = FT.text,
      this.opts = const [],
      this.req = false,
      this.onlyCreate = false,
      this.def,
      this.showIf,
      this.doc = false,
      this.allowAdd = false,
      this.accept,
      this.lettersOnly = false,
      this.digitsOnly = false});

  bool visible(Rec m) => showIf == null || showIf!(m);
}

/// Describe un módulo (Clientes, Ventas, etc.). Las pantallas de lista,
/// detalle y formulario se construyen a partir de esta configuración.
class ModuleCfg {
  final String key, title, singular, idKey;
  final IconData icon;
  final List<Fld> fields;
  final String Function(Rec) titleOf, subOf, extraOf;
  final List<Opt> filters; // filtros por estado (vacío = sin filtro)
  final List<String> searchKeys;
  final bool toggle; // permite activar/inactivar
  final bool canCreate; // permite registrar nuevos (según el alcance del proyecto)
  final List<Rec> data;

  ModuleCfg({
    required this.key,
    required this.title,
    required this.singular,
    required this.icon,
    required this.idKey,
    required this.fields,
    required this.titleOf,
    required this.subOf,
    required this.extraOf,
    required this.data,
    this.filters = const [],
    this.searchKeys = const [],
    this.toggle = false,
    this.canCreate = true,
  });

  String labelOf(String fieldKey, Object? value) {
    if (value == null || '$value'.isEmpty) return '—';
    final f = fields.where((f) => f.key == fieldKey);
    if (f.isNotEmpty) {
      if (f.first.type == FT.check) return value == true ? 'Sí' : 'No';
      if (f.first.type == FT.file) return 'Adjunto';
      for (final o in f.first.opts) {
        if (o.v == '$value') return o.l;
      }
    }
    return '$value';
  }

  List<Fld> get docFields => fields.where((f) => f.doc).toList();
  bool get hasDocs => fields.any((f) => f.doc);

  Object nextId() {
    final ids = data.map((e) => e[idKey]).toList();
    if (ids.isNotEmpty && ids.first is String) {
      final n = ids.map((e) => int.tryParse('$e') ?? 0).fold<int>(0, (a, b) => a > b ? a : b);
      return (n + 1).toString().padLeft(3, '0');
    }
    final n = ids.map((e) => (e is num) ? e.toInt() : 0).fold<int>(0, (a, b) => a > b ? a : b);
    return n + 1;
  }
}
