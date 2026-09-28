import 'dart:async';
import 'package:flutter/material.dart';
import '../core/format.dart';
import '../data.dart';
import '../services/precios_service.dart';
import '../theme.dart';
import 'charts.dart';

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(gradient: metal, borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 12)),
      );
}

/// Contenedor base de todas las tarjetas.
class GmCard extends StatelessWidget {
  const GmCard({super.key, required this.child, this.dark = false});
  final Widget child;
  final bool dark; // tarjeta negra con borde dorado (Precios del día)
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? p.cardTile : p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dark ? const Color(0x88E6B53A) : p.ln),
        boxShadow: const [BoxShadow(color: Color(0x14A8730F), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class CardHeader extends StatelessWidget {
  const CardHeader(this.title, this.sub, {super.key, this.trailing, this.onDark = false});
  final String title, sub;
  final Widget? trailing;
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: onDark ? p.cardTileValue : p.tx)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 12, color: onDark ? p.cardTileLabel : p.mu)),
        ]),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});
  Widget _k(Kpi k, Pal p) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.cardTile,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x88E6B53A)),
          boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k.label, maxLines: 2, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: .5, color: p.cardTileLabel)),
          const SizedBox(height: 4),
          Text(k.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: p.cardTileValue)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: p.cardTilePillBg, borderRadius: BorderRadius.circular(99)),
            child: Text(k.delta, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.cardTilePillText)),
          ),
        ]),
      );

  Widget _row(Pal p, int a, int b) => Row(children: [
        Expanded(child: _k(kpis[a], p)),
        const SizedBox(width: 10),
        Expanded(child: _k(kpis[b], p)),
      ]);

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(children: [
      _row(p, 0, 1),
      const SizedBox(height: 10),
      _row(p, 2, 3),
    ]);
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({super.key});
  Widget _lg(Color c, String t, Color tc) => Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 5),
          Text(t, style: TextStyle(fontSize: 12, color: tc)),
        ]),
      );
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GmCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardHeader('Compra y venta de insumos polimetálicos y oro', 'Últimos 6 meses · valores en USD', trailing: Pill('2026')),
        const SizedBox(height: 10),
        Row(children: [_lg(gold1, 'Ventas', p.mu), _lg(p.barCompras, 'Compras', p.mu)]),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 340 / 190,
          child: CustomPaint(painter: BarsPainter(grid: p.ln, label: p.mu, comprasColor: p.barCompras)),
        ),
      ]),
    );
  }
}

class DistCard extends StatelessWidget {
  const DistCard({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final colors = [gold2, p.bar2, const Color(0xFFF3E2A6)];
    return GmCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CardHeader('Distribución actual de los productos', 'Valores del año 2026'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: goldSoft, borderRadius: BorderRadius.circular(99)),
          child: Row(children: [
            for (final t in ['Día', 'Mes', 'Año'])
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.center,
                  decoration: t == 'Año' ? BoxDecoration(gradient: metal, borderRadius: BorderRadius.circular(99)) : null,
                  child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t == 'Año' ? ink : p.mu)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          SizedBox(width: 130, height: 130, child: CustomPaint(painter: DonutPainter(colors: colors, centerColor: p.tx))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(children: [
              for (var i = 0; i < distribucion.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(distribucion[i].$1, style: TextStyle(color: p.tx))),
                    Text('${distribucion[i].$2}', style: TextStyle(fontWeight: FontWeight.w700, color: p.tx)),
                  ]),
                ),
            ]),
          ),
        ]),
      ]),
    );
  }
}

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GmCard(
      child: Column(children: [
        CardHeader('Pedidos en polimetálicos', 'Compromisos de entrega vigentes', trailing: Pill('${pedidos.length} activos')),
        for (final o in pedidos)
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: const Color(0x1AE6B53A),
                child: IntrinsicHeight(
                  child: Row(children: [
                    Container(width: 5, color: gold2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(o.cliente, style: TextStyle(fontWeight: FontWeight.w700, color: p.tx)),
                              Text('Entrega: ${o.entrega}', style: TextStyle(fontSize: 12, color: p.mu)),
                            ]),
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${o.kg} kg', style: TextStyle(fontWeight: FontWeight.w700, color: p.tx)),
                            Text('Piden: ${o.piden} kg', style: TextStyle(fontSize: 12, color: p.mu)),
                          ]),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class ProductionCard extends StatelessWidget {
  const ProductionCard({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GmCard(
      child: Column(children: [
        const CardHeader('Producción', 'Avance de la orden en curso', trailing: Pill('45% completado')),
        for (final e in produccion)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.$1, style: TextStyle(fontWeight: FontWeight.w600, color: p.tx)),
                Text('${e.$2}%', style: const TextStyle(fontWeight: FontWeight.w600, color: gold3)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(children: [
                  Container(height: 9, color: goldSoft),
                  FractionallySizedBox(
                    widthFactor: e.$2 / 100,
                    child: Container(height: 9, color: gold2),
                  ),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

/// Tarjeta "Precios del día": consulta oro (USD/oz) y USD→COP reales
/// mediante [PreciosService] y se refresca sola cada 5 minutos.
class PricesCard extends StatefulWidget {
  const PricesCard({super.key});
  @override
  State<PricesCard> createState() => _PricesCardState();
}

class _PricesCardState extends State<PricesCard> {
  PreciosData? _datos;
  String? _error, _detalle;
  bool _cargando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargar();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _cargar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (mounted && _datos == null) setState(() => _cargando = true);
    try {
      final datos = await PreciosService.obtener();
      if (!mounted) return;
      setState(() {
        _datos = datos;
        _error = datos.completo ? null : 'Algunos precios no están disponibles por ahora. Toca actualizar para reintentar.';
        _detalle = datos.completo ? null : datos.detalle;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los precios. Revisa tu conexión e intenta de nuevo.';
        _detalle = e is PreciosException ? e.detalle : '$e';
        _cargando = false;
      });
    }
  }

  String _hora(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _v(Pal p, String l, String v) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: const Color(0x55E6B53A)), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: TextStyle(fontSize: 12, color: p.cardTileLabel)),
            Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.cardTileValue)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final d = _datos;
    final usdTxt = d?.usdCop == null ? '\$— —' : '\$${fmtNum(d!.usdCop!, decimals: 2)}';
    final oroTxt = d?.oroUsdOz == null ? '\$— —' : '\$${fmtNum(d!.oroUsdOz!, decimals: 2)}';
    final sub = d == null ? 'Dólar y oro, en tiempo real' : 'Dólar y oro · actualizado ${_hora(d.actualizado)}';
    return GmCard(
      dark: true,
      child: Column(children: [
        CardHeader(
          'Precios del día',
          sub,
          onDark: true,
          trailing: _cargando
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: p.cardTileValue))
              : IconButton(
                  tooltip: 'Actualizar',
                  icon: Icon(Icons.refresh, color: p.cardTileValue, size: 20),
                  onPressed: _cargar,
                ),
        ),
        const SizedBox(height: 12),
        Row(children: [_v(p, 'USD → COP', usdTxt), const SizedBox(width: 10), _v(p, 'Oro (USD/oz)', oroTxt)]),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0x1FE6B53A), borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_error!, style: TextStyle(fontSize: 12, color: p.cardTileValue)),
              if (_detalle != null) ...[
                const SizedBox(height: 6),
                Text(_detalle!, style: TextStyle(fontSize: 10, color: p.cardTileLabel)),
              ],
            ]),
          ),
        ],
      ]),
    );
  }
}