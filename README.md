# GoldMetal App — Frontend móvil (Flutter)

## Cómo correrlo
Este zip trae el código (`lib/`, `assets/`, `pubspec.yaml`). Falta generar las carpetas de plataforma (android/ios):

```bash
cd goldmetal_app
flutter create --project-name goldmetal_app .
flutter pub get
flutter run
```

## Estructura
- `lib/main.dart` — arranque y temas claro/oscuro
- `lib/theme.dart` — paleta dorada y modo claro/oscuro (`themeMode`)
- `lib/data.dart` — datos de ejemplo (reemplazar por la API)
- `lib/models/module_config.dart` — modelo genérico de módulo (campos, filtros, validaciones)
- `lib/modules/modules.dart` — los 11 módulos: Compras, Proveedores, Ventas, Clientes, Pedidos, Insumos oro, Insumos polimetálicos, Producción, Empleados, Usuarios y Roles
- `lib/data/seed.dart` — datos de ejemplo copiados de la versión web
- `lib/widgets/` — gráficos (barras y dona), tarjetas y widgets comunes
- `lib/screens/auth.dart` — Login y Registro
- `lib/screens/home_screen.dart` — Dashboard + menú lateral
- `lib/screens/module_*_screen.dart` — lista, consultar y registrar/editar (genéricos)

Para agregar un campo o módulo nuevo solo se edita `modules.dart`.
- `assets/` — logos (oscuro para modo claro, dorado para modo oscuro)

Requiere Flutter 3.10+ (usa records de Dart 3).
