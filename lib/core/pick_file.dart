import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Abre el selector de archivos del teléfono para elegir un PDF.
///
/// Usa el selector del sistema (no necesita permisos de almacenamiento). Si el
/// filtro por PDF falla en algún teléfono, reintenta sin filtro y valida que el
/// archivo elegido sea .pdf. Devuelve la ruta (o el nombre) del archivo, o null
/// si la persona cancela. Si algo falla, muestra el error real en pantalla.
Future<String?> pickPdf(BuildContext context) async {
  Future<FilePickerResult?> abrir(FileType t) => FilePicker.platform.pickFiles(
        type: t,
        allowedExtensions: t == FileType.custom ? ['pdf'] : null,
        allowMultiple: false,
        withData: kIsWeb,
      );

  FilePickerResult? res;
  try {
    try {
      res = await abrir(FileType.custom);
    } on PlatformException {
      res = await abrir(FileType.any);
    }
  } catch (e) {
    if (context.mounted) {
      final detalle = e is PlatformException ? '${e.code}: ${e.message ?? ''}' : '$e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el selector de archivos. $detalle')));
    }
    return null;
  }
  if (res == null || res.files.isEmpty) return null;
  final f = res.files.single;
  if (!f.name.toLowerCase().endsWith('.pdf')) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solo se permiten archivos PDF.')));
    }
    return null;
  }
  // En web `path` no existe (lanza excepción al leerlo); solo se usa el nombre.
  if (kIsWeb) return f.name;
  return f.path ?? f.name;
}
