// Datos de ejemplo. Reemplazar por la API / backend cuando esté listo.
const months = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
const List<double> ventas = [62, 60, 44, 66, 74, 86];
const List<double> compras = [56, 58, 47, 60, 57, 58];

class Kpi {
  final String label, value, delta;
  final bool gold;
  const Kpi(this.label, this.value, this.delta, {this.gold = false});
}

const kpis = [
  Kpi('VENTAS DEL MES', '\$135.2K', '▲ 13.4%', gold: true),
  Kpi('COMPRAS DEL MES', '\$91.4K', '▲ 10.9%'),
  Kpi('STOCK DE ORO', '2,840 gr', '▼ 3.2%'),
  Kpi('STOCK POLIMETÁLICOS', '4,120 kg', '▲ 5.1%'),
];

class Pedido {
  final String cliente, entrega, kg, piden;
  const Pedido(this.cliente, this.entrega, this.kg, this.piden);
}

const pedidos = [
  Pedido('Joyería El Diamante', '15 sep 2026', '1,200', '1,500'),
  Pedido('Metales Preciosos LTDA', '02 oct 2026', '860', '900'),
  Pedido('Compraventa Rápida', '20 sep 2026', '430', '430'),
];

const produccion = [
  ('Recepción de material', 100),
  ('Procesamiento', 75),
  ('Fundición', 40),
  ('Control de calidad', 10),
  ('Empaque y despacho', 0),
];

// (nombre, valor) — el color se asigna en el widget según el tema.
const distribucion = [('Oro', 58), ('Polimetálicos', 33), ('Otros', 9)];
