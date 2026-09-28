// Datos de ejemplo tomados de tu proyecto web. Reemplazar por la API/backend.
final Map<String, List<Map<String, Object?>>> seed = {
  "roles": [
    {"id_rol": 1, "nombre": "Administrador"},
    {"id_rol": 2, "nombre": "Contador"},
    {"id_rol": 3, "nombre": "Abogado"},
  ],
  "usuarios": [
    {"id_usuario": 1, "correo": "admin@mmmetalsgold.com", "nombre_completo": "Administrador", "telefono": "3001234567", "id_rol": 1, "estado": "ACTIVO"},
    {"id_usuario": 2, "correo": "contador@mmmetalsgold.com", "nombre_completo": "Contador", "telefono": "3012345678", "id_rol": 2, "estado": "ACTIVO"},
    {"id_usuario": 3, "correo": "abogado@mmmetalsgold.com", "nombre_completo": "Abogado", "telefono": "3023456789", "id_rol": 3, "estado": "ACTIVO"},
  ],
  "compras": [
    {"id": "001", "proveedor": "Proveedor asociado 1", "acopio": "Acopio principal", "fecha": "23/09/2026", "moneda": "COP", "valorTotal": "\$5.000.000", "estado": "REGISTRADA"},
    {"id": "002", "proveedor": "Proveedor asociado 2", "acopio": "Acopio principal", "fecha": "22/09/2026", "moneda": "COP", "valorTotal": "\$8.500.000", "estado": "APROBADA"},
    {"id": "003", "proveedor": "Proveedor asociado 3", "acopio": "Acopio secundario", "fecha": "20/09/2026", "moneda": "USD", "valorTotal": "\$3.200", "estado": "CANCELADA"},
  ],
  "proveedores": [
    {"id": "001", "razon_social": "Proveedor Minero Chocó", "tipo_persona": "JURIDICA", "numero_documento": "900123456", "estado": "ACTIVO"},
    {"id": "002", "razon_social": "Proveedor Minero Bolívar", "tipo_persona": "JURIDICA", "numero_documento": "900234567", "estado": "ACTIVO"},
    {"id": "003", "razon_social": "Proveedor Natural", "tipo_persona": "NATURAL", "numero_documento": "1234567890", "estado": "INACTIVO"},
  ],
  "produccion": [
    {"id": "001", "id_orden_produccion": 1, "id_acopio": 1, "pedido": "PED-001", "cliente": "M&M Trading S.A.S.", "insumo": "Material polimetálico", "cantidad": "500 kg", "fecha": "23/09/2026", "fecha_entrega": "23/10/2026", "responsable": "Responsable de producción"},
    {"id": "002", "id_orden_produccion": 2, "id_acopio": 2, "pedido": "PED-002", "cliente": "Global Metals International", "insumo": "Oro", "cantidad": "250 g", "fecha": "22/09/2026", "fecha_entrega": "22/10/2026", "responsable": "Responsable de producción"},
    {"id": "003", "id_orden_produccion": 3, "id_acopio": 3, "pedido": "PED-003", "cliente": "M&M Trading S.A.S.", "insumo": "Material polimetálico", "cantidad": "300 kg", "fecha": "20/09/2026", "fecha_entrega": "20/10/2026", "responsable": "Responsable de producción"},
  ],
  "empleados": [
    {"id_empleado": 1, "nombre_completo": "Carlos Andrés Gómez", "numero_documento": "1032456789", "telefono": "3001234567", "estado": "ACTIVO", "id_usuario": null},
    {"id_empleado": 2, "nombre_completo": "Laura Marcela Pérez", "numero_documento": "1012456788", "telefono": "3019876543", "estado": "ACTIVO", "id_usuario": null},
    {"id_empleado": 3, "nombre_completo": "Juan David Rodríguez", "numero_documento": "98567432", "telefono": "3154567890", "estado": "INACTIVO", "id_usuario": null},
  ],
  "ventas": [
    {"id_venta": 1, "cliente": "M&M Trading S.A.S.", "pedido": "PED-001", "tipo_material": "Oro en lingote", "cantidad": "500 g", "precio": "120000000", "moneda": "COP", "fecha": "2026-09-20", "pais_destino": "India", "estado": "REGISTRADA", "pagado": true, "producido": true, "encargado_transporte": "Carlos Gómez", "placa_vehiculo": "ABC123", "certificado_origen": "documento_adjunto", "factura": "documento_adjunto", "regalias": "documento_adjunto"},
    {"id_venta": 2, "cliente": "Global Metals International", "pedido": "PED-002", "tipo_material": "Arena procesada", "cantidad": "1.000 kg", "precio": "85000000", "moneda": "COP", "fecha": "2026-09-18", "pais_destino": "China", "estado": "DESPACHADA", "pagado": true, "producido": true, "encargado_transporte": "Juan Rodríguez", "placa_vehiculo": "XYZ789", "certificado_origen": "documento_adjunto", "factura": "documento_adjunto", "regalias": ""},
    {"id_venta": 3, "cliente": "Global Metals International", "pedido": "PED-003", "tipo_material": "Oro en lingote", "cantidad": "250 g", "precio": "62000000", "moneda": "COP", "fecha": "2026-09-15", "pais_destino": "Estados Unidos", "estado": "CANCELADA", "pagado": false, "producido": false, "certificado_origen": "", "factura": "", "regalias": ""},
  ],
  "clientes": [
    {"id_cliente": 1, "tipo_cliente": "JURIDICA", "nombre": "M&M Trading S.A.S.", "identificacion_tributaria": "900123456-1", "pais": "Colombia", "ciudad": "Medellín", "camara_comercio": "CC-2026-001", "rut": "900123456-1", "rucom": "RUCOM-001234", "contrato": "CON-2026-001", "estado": "ACTIVO"},
    {"id_cliente": 2, "tipo_cliente": "JURIDICA", "nombre": "Global Metals International", "identificacion_tributaria": "901234567-8", "pais": "Estados Unidos", "ciudad": "Miami", "camara_comercio": "CC-2026-002", "rut": "901234567-8", "rucom": "RUCOM-005678", "contrato": "CON-2026-002", "estado": "ACTIVO"},
  ],
  "pedidos": [
    {"id_pedido": 1, "cliente": "M&M Trading S.A.S.", "acopio": "Acopio Chocó", "fecha_pedido": "2026-09-20", "estado": "ABIERTO", "moneda": "COP", "tasa_cambio": null, "valor_total": 125000000, "valor_pagado": 112500000, "porcentaje_pago_inicial": 0.9},
    {"id_pedido": 2, "cliente": "Global Metals International", "acopio": "Acopio Bolívar", "fecha_pedido": "2026-09-18", "estado": "EN_PRODUCCION", "moneda": "USD", "tasa_cambio": 4200, "valor_total": 28500, "valor_pagado": 25650, "porcentaje_pago_inicial": 0.9},
    {"id_pedido": 3, "cliente": "M&M Trading S.A.S.", "acopio": "Acopio Chocó", "fecha_pedido": "2026-09-15", "estado": "LISTO", "moneda": "COP", "tasa_cambio": null, "valor_total": 85000000, "valor_pagado": 76500000, "porcentaje_pago_inicial": 0.9},
  ],
  "insumosOro": [
    {"id_insumo": 1, "tipo_insumo": "ORO", "nombre": "Oro", "cantidad": 500, "unidad_medida": "g", "estado": "ACTIVO"},
    {"id_insumo": 2, "tipo_insumo": "ORO", "nombre": "Oro en polvo", "cantidad": 250, "unidad_medida": "g", "estado": "ACTIVO"},
    {"id_insumo": 3, "tipo_insumo": "ORO", "nombre": "Oro en lingote", "cantidad": 2000, "unidad_medida": "g", "estado": "INACTIVO"},
  ],
  "insumosPolimetalicos": [
    {"id_insumo": 1, "tipo_insumo": "POLIMETALICO", "nombre": "Arena polimetálica", "cantidad": 500, "unidad_medida": "g_t", "estado": "ACTIVO", "mina": "Mina Chocó", "acopio": "Acopio principal"},
    {"id_insumo": 2, "tipo_insumo": "POLIMETALICO", "nombre": "Arena polimetálica fina", "cantidad": 250, "unidad_medida": "g_t", "estado": "ACTIVO", "mina": "Mina Bolívar", "acopio": "Acopio Bolívar"},
    {"id_insumo": 3, "tipo_insumo": "POLIMETALICO", "nombre": "Material polimetálico de acopio", "cantidad": 100, "unidad_medida": "g_t", "estado": "INACTIVO", "mina": "Mina Chocó", "acopio": "Acopio Chocó"},
  ],
};
