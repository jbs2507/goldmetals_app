import 'package:flutter/material.dart';
import '../data/seed.dart';
import '../models/module_config.dart';

List<Rec> _d(String k) => seed[k]!.map((e) => Rec.of(e)).toList();
String _s(Rec m, String k) => '${m[k] ?? '—'}';

const _estados = [Opt('ACTIVO', 'Activo'), Opt('INACTIVO', 'Inactivo')];
const _estado = Fld('estado', 'Estado', type: FT.select, opts: _estados, def: 'ACTIVO');
const _acopios = [Opt('Acopio principal'), Opt('Acopio Chocó'), Opt('Acopio Bolívar')];
const _insumos = [Opt('Oro'), Opt('Material polimetálico')];
// Unidades de medida: el oro parte solo en gramos y los polimetálicos en g/t,
// pero se puede agregar una nueva unidad desde el formulario (botón "Agregar nuevo").
final List<Opt> _unidadesOro = [Opt('g', 'Gramos (g)')];
final List<Opt> _unidadesPoli = [Opt('g_t', 'Gramos por tonelada (g/t)')];
const _clientes = [Opt('M&M Trading S.A.S.'), Opt('Global Metals International')];
// Lista de países de clientes: empieza con estos 3, se le pueden agregar más desde el
// formulario, y también incluye los que ya tuvieran registrados los clientes existentes.
final List<Opt> _paises = () {
  final list = [Opt('China'), Opt('Singapur'), Opt('Estados Unidos')];
  for (final c in seed['clientes'] ?? const []) {
    final p = '${c['pais'] ?? ''}'.trim();
    if (p.isNotEmpty && !list.any((o) => o.v.toLowerCase() == p.toLowerCase())) list.add(Opt(p));
  }
  return list;
}();
const _pedidos = [Opt('PED-001'), Opt('PED-002'), Opt('PED-003')];
const _roles = [Opt('1', 'Administrador'), Opt('2', 'Contador'), Opt('3', 'Abogado')];
bool _listoParaTransporte(Rec m) => m['pagado'] == true && m['producido'] == true;
String _rolLabel(Object? v) => _roles.firstWhere((o) => o.v == '$v', orElse: () => const Opt('', '—')).l;

final List<ModuleCfg> modules = [
  ModuleCfg(
    key: 'compras', title: 'Compras', singular: 'compra', icon: Icons.shopping_cart_outlined, idKey: 'id',
    fields: [
      Fld('fecha', 'Fecha de compra', type: FT.date),
      Fld('proveedor', 'Proveedor asociado', type: FT.select, opts: [Opt('Proveedor asociado 1'), Opt('Proveedor asociado 2'), Opt('Proveedor asociado 3')]),
      Fld('acopio', 'Acopio', type: FT.select, opts: [Opt('Acopio principal'), Opt('Acopio secundario')]),
      Fld('estado', 'Estado', type: FT.select, opts: [Opt('REGISTRADA', 'Registrada'), Opt('APROBADA', 'Aprobada'), Opt('CANCELADA', 'Cancelada')], def: 'REGISTRADA'),
      Fld('peso', 'Peso', type: FT.number),
      Fld('ley', 'Ley', type: FT.number),
      Fld('precioUnitario', 'Precio unitario', type: FT.number),
      Fld('valorRegalias', 'Valor de regalías', type: FT.number),
      Fld('valorTotal', 'Valor total'),
      Fld('certificadoOrigen', 'Certificado de origen', type: FT.file, accept: 'pdf', req: true),
      Fld('resultadoLaboratorio', 'Resultado de laboratorio', type: FT.file, accept: 'pdf', req: true),
    ],
    titleOf: (m) => 'Compra #${_s(m, 'id')}',
    subOf: (m) => '${_s(m, 'proveedor')} · ${_s(m, 'acopio')}',
    extraOf: (m) => '${_s(m, 'fecha')} · ${_s(m, 'valorTotal')}',
    filters: const [Opt('REGISTRADA', 'Registrada'), Opt('APROBADA', 'Aprobada'), Opt('CANCELADA', 'Cancelada')],
    searchKeys: const ['id', 'proveedor', 'acopio'],
    data: _d('compras'),
  ),
  ModuleCfg(
    key: 'proveedores', title: 'Proveedores', singular: 'proveedor', icon: Icons.local_shipping_outlined, idKey: 'id',
    fields: const [
      Fld('tipo_persona', 'Tipo de persona', type: FT.select, opts: [Opt('NATURAL', 'Natural'), Opt('JURIDICA', 'Jurídica')], req: true),
      Fld('razon_social', 'Nombre / Razón social', req: true, lettersOnly: true),
      Fld('numero_documento', 'Número de documento', req: true, digitsOnly: true),
      _estado,
    ],
    titleOf: (m) => _s(m, 'razon_social'),
    subOf: (m) => '${_s(m, 'tipo_persona')} · Doc. ${_s(m, 'numero_documento')}',
    extraOf: (m) => 'Proveedor #${_s(m, 'id')}',
    filters: _estados, searchKeys: const ['razon_social', 'numero_documento'], toggle: true, canCreate: false,
    data: _d('proveedores'),
  ),
  ModuleCfg(
    key: 'ventas', title: 'Ventas', singular: 'venta', icon: Icons.trending_up, idKey: 'id_venta',
    fields: [
      Fld('cliente', 'Cliente', type: FT.select, opts: _clientes, req: true),
      Fld('pedido', 'Pedido', type: FT.select, opts: _pedidos, req: true),
      Fld('tipo_material', 'Tipo de material', type: FT.select, opts: [Opt('Oro en lingote'), Opt('Arena procesada')], req: true),
      Fld('cantidad', 'Cantidad', req: true),
      Fld('precio', 'Precio', type: FT.number, req: true),
      Fld('moneda', 'Moneda', type: FT.select, opts: [Opt('COP', 'COP - Peso colombiano'), Opt('USD', 'USD - Dólar estadounidense')], def: 'COP'),
      Fld('fecha', 'Fecha', type: FT.date),
      Fld('pais_destino', 'País destino', lettersOnly: true),
      Fld('estado', 'Estado', type: FT.select, opts: [Opt('REGISTRADA', 'Registrada'), Opt('DESPACHADA', 'Despachada'), Opt('ENTREGADA', 'Entregada'), Opt('CANCELADA', 'Cancelada')], def: 'REGISTRADA'),
      Fld('pagado', 'Pago recibido', type: FT.check),
      Fld('producido', 'Producción lista', type: FT.check),
      // Estos dos solo se habilitan (en el formulario y el detalle) cuando la venta ya está pagada y producida.
      Fld('encargado_transporte', 'Encargado de transporte', showIf: _listoParaTransporte, lettersOnly: true),
      Fld('placa_vehiculo', 'Placa del vehículo', showIf: _listoParaTransporte),
      // Documentos de la venta: se gestionan aparte, en el submenú "Documentos".
      Fld('factura', 'Factura', type: FT.file, doc: true, accept: 'pdf'),
      Fld('certificado_laboratorio', 'Certificado de laboratorio', type: FT.file, doc: true, accept: 'pdf'),
    ],
    titleOf: (m) => _s(m, 'cliente'),
    subOf: (m) => '${_s(m, 'pedido')} · ${_s(m, 'tipo_material')}',
    extraOf: (m) => '${_s(m, 'fecha')} · ${_s(m, 'cantidad')} · ${_s(m, 'precio')} ${_s(m, 'moneda')}',
    filters: const [Opt('REGISTRADA', 'Registrada'), Opt('DESPACHADA', 'Despachada'), Opt('ENTREGADA', 'Entregada'), Opt('CANCELADA', 'Cancelada')],
    searchKeys: const ['cliente', 'pedido', 'tipo_material'],
    data: _d('ventas'),
  ),
  ModuleCfg(
    key: 'clientes', title: 'Clientes', singular: 'cliente', icon: Icons.people_alt_outlined, idKey: 'id_cliente',
    fields: [
      Fld('tipo_cliente', 'Tipo de cliente', type: FT.select, opts: [Opt('JURIDICA', 'Jurídica'), Opt('NATURAL', 'Natural')], def: 'JURIDICA', req: true),
      Fld('nombre', 'Nombre / Razón social', req: true, lettersOnly: true),
      Fld('identificacion_tributaria', 'Identificación tributaria', req: true, digitsOnly: true),
      Fld('pais', 'País', type: FT.select, opts: _paises, allowAdd: true, req: true),
      _estado,
      Fld('doc_camara', 'Documento Cámara de Comercio', type: FT.file, accept: 'pdf', req: true),
      Fld('doc_contrato', 'Documento Contrato', type: FT.file, accept: 'pdf', req: true),
    ],
    titleOf: (m) => _s(m, 'nombre'),
    subOf: (m) => '${_s(m, 'tipo_cliente')} · ${_s(m, 'pais')}',
    extraOf: (m) => 'ID tributaria ${_s(m, 'identificacion_tributaria')}',
    filters: _estados, searchKeys: const ['nombre', 'identificacion_tributaria'], toggle: true,
    data: _d('clientes'),
  ),
  ModuleCfg(
    key: 'pedidos', title: 'Pedidos', singular: 'pedido', icon: Icons.receipt_long_outlined, idKey: 'id_pedido',
    fields: const [
      Fld('cliente', 'Cliente', type: FT.select, opts: _clientes),
      Fld('acopio', 'Acopio', type: FT.select, opts: _acopios),
      Fld('fecha_pedido', 'Fecha del pedido', type: FT.date),
      Fld('estado', 'Estado', type: FT.select, opts: [Opt('ABIERTO', 'Abierto'), Opt('EN_PRODUCCION', 'En producción'), Opt('LISTO', 'Listo'), Opt('ENTREGADO', 'Entregado'), Opt('CANCELADO', 'Cancelado')], def: 'ABIERTO'),
      Fld('moneda', 'Moneda', type: FT.select, opts: [Opt('COP'), Opt('USD')], def: 'COP'),
      Fld('tasa_cambio', 'Tasa de cambio', type: FT.number),
      Fld('valor_total', 'Valor total', type: FT.number),
      Fld('valor_pagado', 'Valor pagado', type: FT.number),
      Fld('porcentaje_pago_inicial', 'Porcentaje de pago inicial', type: FT.number),
      Fld('insumo', 'Insumo', type: FT.select, opts: _insumos),
      Fld('cantidad', 'Cantidad', type: FT.number),
      Fld('precio_unitario', 'Precio unitario', type: FT.number),
      Fld('fecha_pago', 'Fecha de pago', type: FT.date),
      Fld('banco_pago', 'Cuenta a la que pagaron', type: FT.select, opts: [Opt('BANCOLOMBIA', 'Bancolombia'), Opt('DAVIVIENDA', 'Davivienda')]),
      Fld('comprobante_pago', 'Comprobante de pago', type: FT.file, accept: 'image', req: true),
      Fld('fecha_entrega', 'Fecha de entrega (1 mes después de la fecha)', type: FT.date),
    ],
    titleOf: (m) => 'Pedido #${_s(m, 'id_pedido')} · ${_s(m, 'cliente')}',
    subOf: (m) => '${_s(m, 'acopio')} · ${_s(m, 'fecha_pedido')}',
    extraOf: (m) => 'Total ${_s(m, 'valor_total')} ${_s(m, 'moneda')} · Pagado ${_s(m, 'valor_pagado')}',
    filters: const [Opt('ABIERTO', 'Abierto'), Opt('EN_PRODUCCION', 'En producción'), Opt('LISTO', 'Listo'), Opt('ENTREGADO', 'Entregado'), Opt('CANCELADO', 'Cancelado')],
    searchKeys: const ['id_pedido', 'cliente', 'acopio'],
    data: _d('pedidos'),
  ),
  ModuleCfg(
    key: 'insumosOro', title: 'Insumos de oro', singular: 'insumo de oro', icon: Icons.diamond_outlined, idKey: 'id_insumo',
    fields: [
      Fld('tipo_insumo', 'Tipo de insumo', def: 'ORO'),
      Fld('nombre', 'Nombre', req: true, lettersOnly: true),
      Fld('cantidad', 'Cantidad', type: FT.number, req: true),
      Fld('unidad_medida', 'Unidad de medida', type: FT.select, opts: _unidadesOro, def: 'g', allowAdd: true),
      _estado,
    ],
    titleOf: (m) => _s(m, 'nombre'),
    subOf: (m) => '${_s(m, 'cantidad')} ${_s(m, 'unidad_medida')}',
    extraOf: (m) => _s(m, 'tipo_insumo'),
    filters: _estados, searchKeys: const ['nombre'], toggle: true, canCreate: false,
    data: _d('insumosOro'),
  ),
  ModuleCfg(
    key: 'insumosPolimetalicos', title: 'Insumos polimetálicos', singular: 'insumo polimetálico', icon: Icons.hexagon_outlined, idKey: 'id_insumo',
    fields: [
      Fld('tipo_insumo', 'Tipo de insumo', def: 'POLIMETALICO'),
      Fld('nombre', 'Nombre', req: true, lettersOnly: true),
      Fld('cantidad', 'Cantidad', type: FT.number, req: true),
      Fld('unidad_medida', 'Unidad de medida', type: FT.select, opts: _unidadesPoli, def: 'g_t', allowAdd: true),
      Fld('mina', 'Mina de origen', type: FT.select, opts: [Opt('Mina Chocó'), Opt('Mina Bolívar')], req: true),
      Fld('acopio', 'Acopio', type: FT.select, opts: _acopios, req: true),
      _estado,
    ],
    titleOf: (m) => _s(m, 'nombre'),
    subOf: (m) => '${_s(m, 'cantidad')} ${_s(m, 'unidad_medida')} · ${_s(m, 'mina')}',
    extraOf: (m) => _s(m, 'acopio'),
    filters: _estados, searchKeys: const ['nombre', 'mina', 'acopio'], toggle: true, canCreate: false,
    data: _d('insumosPolimetalicos'),
  ),
  ModuleCfg(
    key: 'produccion', title: 'Producción', singular: 'registro de producción', icon: Icons.precision_manufacturing_outlined, idKey: 'id',
    fields: const [
      Fld('id_orden_produccion', 'Orden de producción', type: FT.select, opts: [Opt('1', 'Orden de producción disponible')]),
      Fld('id_acopio', 'Acopio', type: FT.select, opts: [Opt('1', 'Acopio disponible')]),
      Fld('pedido', 'Pedido', type: FT.select, opts: _pedidos, req: true),
      Fld('cliente', 'Cliente', type: FT.select, opts: _clientes, req: true),
      Fld('insumo', 'Insumo / material', type: FT.select, opts: _insumos),
      Fld('cantidad', 'Cantidad'),
      Fld('fecha', 'Fecha', type: FT.date),
      Fld('responsable', 'Responsable', lettersOnly: true),
    ],
    titleOf: (m) => 'Producción #${_s(m, 'id')}',
    subOf: (m) => '${_s(m, 'cliente')} · ${_s(m, 'pedido')}',
    extraOf: (m) => '${_s(m, 'insumo')} · ${_s(m, 'cantidad')} · Entrega ${_s(m, 'fecha_entrega')}',
    searchKeys: const ['id', 'pedido', 'cliente', 'insumo', 'responsable'],
    data: _d('produccion'),
  ),
  ModuleCfg(
    key: 'empleados', title: 'Empleados', singular: 'empleado', icon: Icons.badge_outlined, idKey: 'id_empleado',
    fields: const [
      Fld('nombre_completo', 'Nombre completo', req: true, lettersOnly: true),
      Fld('numero_documento', 'Número de documento', req: true, digitsOnly: true),
      Fld('telefono', 'Teléfono', digitsOnly: true),
      _estado,
      Fld('id_usuario', 'Usuario asociado', type: FT.number),
    ],
    titleOf: (m) => _s(m, 'nombre_completo'),
    subOf: (m) => 'Doc. ${_s(m, 'numero_documento')}',
    extraOf: (m) => 'Tel. ${_s(m, 'telefono')}',
    filters: _estados, searchKeys: const ['nombre_completo', 'numero_documento', 'telefono'], toggle: true,
    data: _d('empleados'),
  ),
  ModuleCfg(
    key: 'usuarios', title: 'Usuarios', singular: 'usuario', icon: Icons.manage_accounts_outlined, idKey: 'id_usuario',
    fields: const [
      Fld('nombre_completo', 'Nombre completo', req: true, lettersOnly: true),
      Fld('correo', 'Correo', type: FT.email, req: true),
      Fld('telefono', 'Teléfono', digitsOnly: true),
      Fld('id_rol', 'Rol', type: FT.select, opts: _roles, req: true),
      _estado,
      Fld('contrasena', 'Contraseña', type: FT.password, req: true, onlyCreate: true),
    ],
    titleOf: (m) => _s(m, 'nombre_completo'),
    subOf: (m) => _s(m, 'correo'),
    extraOf: (m) => 'Tel. ${_s(m, 'telefono')} · ${_rolLabel(m['id_rol'])}',
    filters: _estados, searchKeys: const ['nombre_completo', 'correo', 'telefono'], toggle: true,
    data: _d('usuarios'),
  ),
  ModuleCfg(
    key: 'roles', title: 'Roles', singular: 'rol', icon: Icons.vpn_key_outlined, idKey: 'id_rol',
    fields: const [Fld('nombre', 'Nombre del rol', req: true, lettersOnly: true)],
    titleOf: (m) => _s(m, 'nombre'),
    subOf: (m) => 'Rol #${_s(m, 'id_rol')}',
    extraOf: (m) => '',
    searchKeys: const ['nombre'], canCreate: false,
    data: _d('roles'),
  ),
];

ModuleCfg moduleByKey(String k) => modules.firstWhere((m) => m.key == k);
