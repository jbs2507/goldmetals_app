// Formatos iguales a los de la web.

String fmtNum(num n, {String thousands = '.', String decimal = ',', int decimals = 0, bool group = true}) {
  final s = n.abs().toStringAsFixed(decimals);
  final parts = s.split('.');
  var i = parts[0];
  if (group) {
    final b = StringBuffer();
    for (var k = 0; k < i.length; k++) {
      if (k > 0 && (i.length - k) % 3 == 0) b.write(thousands);
      b.write(i[k]);
    }
    i = b.toString();
  }
  return '${n < 0 ? '-' : ''}$i${decimals > 0 ? decimal + parts[1] : ''}';
}

/// formatearValor de Pedidos: USD -> $ 1,234.56 ; COP -> $ 1.234.567
String formatearValor(Object? valor, Object? moneda) {
  final n = num.tryParse('$valor') ?? 0;
  if (moneda == 'USD') return '\$ ${fmtNum(n, thousands: ',', decimal: '.', decimals: 2)}';
  return '\$ ${fmtNum(n)}';
}

/// formatearPrecio de Ventas (es-CO): 120000000 -> 120.000.000
String formatearPrecio(Object? p) {
  final n = num.tryParse('$p');
  if (n == null) return '$p';
  return fmtNum(n, group: n.abs() >= 10000);
}

String formatearUnidad(Object? u) => const {
      'g': 'Gramos (g)',
      'kg': 'Kilogramos (kg)',
      'oz': 'Onzas (oz)',
      'lb': 'Libras (lb)',
    }['$u'] ?? '$u';

String formatearEstado(Object? e) => e == 'EN_PRODUCCION' ? 'EN PRODUCCIÓN' : '$e'.replaceAll('_', ' ');

String tipoPersona(Object? t) => t == 'JURIDICA' ? 'Persona jurídica' : 'Persona natural';

/// Texto o valor por defecto cuando está vacío.
String orElse(Object? v, [String fallback = '—']) => (v == null || '$v'.isEmpty) ? fallback : '$v';
