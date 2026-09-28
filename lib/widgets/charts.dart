import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

void _text(Canvas c, String t, Offset o, Color col, {double size = 11, FontWeight w = FontWeight.normal}) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: TextStyle(color: col, fontSize: size, fontWeight: w)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, o - Offset(tp.width / 2, 0));
}

/// Barras de Ventas (dorado) vs Compras (oscuro/bronce).
class BarsPainter extends CustomPainter {
  BarsPainter({required this.grid, required this.label, this.comprasColor = gold3});
  final Color grid, label, comprasColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bw = (w - 40) / 6;
    final gp = Paint()..color = grid..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = 10 + i * (h - 40) / 3;
      canvas.drawLine(Offset(30, y), Offset(w, y), gp);
    }
    for (var i = 0; i < months.length; i++) {
      final x = 34 + i * bw;
      final a = (ventas[i] - 20) * (h - 40) / 70;
      final b = (compras[i] - 20) * (h - 40) / 70;
      final r1 = Rect.fromLTWH(x, h - 20 - a, bw * .34, a);
      final r2 = Rect.fromLTWH(x + bw * .38, h - 20 - b, bw * .34, b);
      canvas.drawRRect(RRect.fromRectAndRadius(r1, const Radius.circular(5)), Paint()..color = gold1);
      canvas.drawRRect(RRect.fromRectAndRadius(r2, const Radius.circular(5)), Paint()..color = comprasColor);
      _text(canvas, months[i], Offset(x + bw * .36, h - 15), label);
    }
  }

  @override
  bool shouldRepaint(BarsPainter o) => o.grid != grid || o.label != label || o.comprasColor != comprasColor;
}

/// Dona de distribución de productos.
class DonutPainter extends CustomPainter {
  DonutPainter({required this.colors, required this.centerColor, this.label = '2026'});
  final List<Color> colors;
  final Color centerColor;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    var start = -math.pi / 2;
    for (var i = 0; i < distribucion.length; i++) {
      final sweep = 2 * math.pi * distribucion[i].$2 / 100;
      canvas.drawArc(
        rect, start + .03, sweep - .06, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 18..color = colors[i],
      );
      start += sweep;
    }
    _text(canvas, label, size.center(Offset.zero) - const Offset(0, 10), centerColor, size: 18, w: FontWeight.w800);
  }

  @override
  bool shouldRepaint(DonutPainter o) => o.colors != colors || o.centerColor != centerColor;
}
