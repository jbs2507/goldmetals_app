// Servicio de precios en vivo: oro (USD por onza troy) y tasa USD -> COP.
//
// Cada dato se consulta POR SEPARADO y con varias fuentes de respaldo, así si
// una API falla (o cambia su formato) la app prueba la siguiente en vez de
// dejar toda la tarjeta en error. Además se conserva el último valor bueno.
//
//  - Oro:   gold-api.com  ->  goldprice.org
//  - Dólar: open.er-api.com  ->  currency-api (jsDelivr)  ->  currency-api (pages.dev)
//
// Si tienes tu propio backend, basta con cambiar/añadir fuentes en las listas.

import 'dart:convert';
import 'package:http/http.dart' as http;

class PreciosData {
  final double? oroUsdOz;
  final double? usdCop;
  final DateTime actualizado;
  final String? detalle; // motivo técnico del fallo (para diagnosticar en el celular)
  const PreciosData({this.oroUsdOz, this.usdCop, required this.actualizado, this.detalle});
  bool get completo => oroUsdOz != null && usdCop != null;
}

typedef _Lector = double? Function(dynamic json);

class _Fuente {
  const _Fuente(this.url, this.leer);
  final String url;
  final _Lector leer;
}

double? _num(dynamic v) {
  if (v == null) return null;
  final n = v is num ? v.toDouble() : double.tryParse('$v');
  return (n != null && n.isFinite && n > 0) ? n : null;
}

class PreciosService {
  static const _timeout = Duration(seconds: 12);
  static const _headers = {'Accept': 'application/json', 'User-Agent': 'GoldMetalApp/1.0'};

  static final List<_Fuente> _fuentesOro = [
    _Fuente('https://api.gold-api.com/price/XAU', (j) => _num(j is Map ? j['price'] : null)),
    _Fuente('https://data-asg.goldprice.org/dbXRates/USD', (j) {
      final items = j is Map ? j['items'] : null;
      return (items is List && items.isNotEmpty && items.first is Map) ? _num((items.first as Map)['xauPrice']) : null;
    }),
  ];

  static final List<_Fuente> _fuentesDolar = [
    _Fuente('https://open.er-api.com/v6/latest/USD', (j) {
      final r = j is Map ? j['rates'] : null;
      return r is Map ? _num(r['COP']) : null;
    }),
    _Fuente('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json', (j) {
      final r = j is Map ? j['usd'] : null;
      return r is Map ? _num(r['cop']) : null;
    }),
    _Fuente('https://latest.currency-api.pages.dev/v1/currencies/usd.json', (j) {
      final r = j is Map ? j['usd'] : null;
      return r is Map ? _num(r['cop']) : null;
    }),
  ];

  // Último valor bueno (se usa si todas las fuentes fallan en un refresco).
  static double? _ultimoOro, _ultimoCop;

  static String _motivo(Object e) {
    final t = '$e'.replaceAll(RegExp(r'\s+'), ' ');
    final txt = t.length > 90 ? '${t.substring(0, 90)}…' : t;
    return '${e.runtimeType}: $txt';
  }

  static Future<(double?, List<String>)> _primeraQueResponda(String nombre, List<_Fuente> fuentes) async {
    final errores = <String>[];
    for (final f in fuentes) {
      final host = Uri.parse(f.url).host;
      try {
        final res = await http.get(Uri.parse(f.url), headers: _headers).timeout(_timeout);
        if (res.statusCode != 200) {
          errores.add('$nombre/$host: HTTP ${res.statusCode}');
          continue;
        }
        final valor = f.leer(jsonDecode(utf8.decode(res.bodyBytes)));
        if (valor != null) return (valor, errores);
        errores.add('$nombre/$host: formato inesperado');
      } catch (e) {
        errores.add('$nombre/$host: ${_motivo(e)}');
      }
    }
    return (null, errores);
  }

  /// Consulta oro y dólar en paralelo. Si una fuente falla, usa su respaldo.
  /// Lanza [Exception] solo si no hay ningún dato (ni nuevo ni guardado).
  static Future<PreciosData> obtener() async {
    final r = await Future.wait([_primeraQueResponda('oro', _fuentesOro), _primeraQueResponda('dólar', _fuentesDolar)]);
    _ultimoOro = r[0].$1 ?? _ultimoOro;
    _ultimoCop = r[1].$1 ?? _ultimoCop;
    final errores = [
      if (r[0].$1 == null) ...r[0].$2,
      if (r[1].$1 == null) ...r[1].$2,
    ];
    final detalle = errores.isEmpty ? null : errores.join('\n');
    if (_ultimoOro == null && _ultimoCop == null) {
      throw PreciosException(detalle ?? 'Sin datos');
    }
    return PreciosData(oroUsdOz: _ultimoOro, usdCop: _ultimoCop, actualizado: DateTime.now(), detalle: detalle);
  }
}

class PreciosException implements Exception {
  PreciosException(this.detalle);
  final String detalle;
  @override
  String toString() => detalle;
}
