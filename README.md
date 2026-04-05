# Invex Up

Aplicación web interactiva para el manejo de fondos de inversión (FPV/FIC), desarrollada en Flutter como parte de una prueba técnica de ingeniería frontend.

> **Disclaimer:** Este repositorio no corresponde a código oficial de BTG Pactual. Únicamente corresponde a una prueba técnica personal desarrollada como parte de un proceso de selección.

---

## Capturas

<p align="center">
  <img src="docs/screenshots/mobile.png" alt="Vista móvil" width="700"/>
</p>

<p align="center">
  <img src="docs/screenshots/web-fondos.png" alt="Web — Fondos disponibles" width="700"/>
</p>

<p align="center">
  <img src="docs/screenshots/web-portafolio.png" alt="Web — Portafolio" width="700"/>
</p>

---

## Funcionalidades

- **Fondos disponibles** — listado con filtros por categoría (FPV / FIC), shimmer loading y estado de error con pull-to-refresh
- **Suscripción a fondos** — validación de monto mínimo, saldo disponible y selección de método de notificación (Email / SMS)
- **Cancelación de suscripción** — desde el detalle del fondo activo en el portafolio, con confirmación y reintegro de saldo
- **Portafolio** — saldo disponible, total invertido, fondos activos y gráfico de distribución interactivo (barra segmentada + dona)
- **Historial de transacciones** — lista cronológica con filtros por tipo (Suscripciones / Cancelaciones)
- **Mensajes de error** — feedback visual cuando el saldo es insuficiente o el monto no cumple el mínimo
- **Diseño responsivo** — layout adaptado para móvil y web (sidebar en pantallas ≥ 600px)
- **Tema claro / oscuro** — toggle desde la app bar

---

## Stack técnico

| Capa | Tecnología |
|---|---|
| Framework | Flutter 3.41 |
| Estado | Riverpod 3 (`NotifierProvider`) |
| Navegación | Flutter Navigator con `IndexedStack` |
| Gráficos | fl_chart |
| Fuentes | Google Fonts (Inter) |
| Formato de moneda | `intl` (locale `es_CO`) |
| Tests | flutter_test |

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── theme/          # AppTheme, colores, tipografía
│   └── utils/          # CurrencyFormatter, DateFormatter, validadores, etc.
├── data/
│   └── models/         # Fund, Transaction, enums
├── features/
│   ├── funds/          # Pantalla de fondos y widgets
│   ├── portfolio/      # Portafolio, gráfico de distribución
│   ├── transactions/   # Historial con filtros
│   └── home/           # Shell de navegación (móvil + web)
├── providers/          # portfolioProvider, fundsProvider, tabProvider
└── shared/
    └── widgets/        # AppBar, EmptyState, StaggeredItem, etc.
```

---

## Cómo ejecutar localmente

### Requisitos

- Flutter 3.x — verificar con `flutter --version`
- Chrome (para web) o un emulador/dispositivo conectado

### Pasos

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd coding_challenge_mateot

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en web
flutter run -d chrome

# 4. Ejecutar en móvil (con emulador o dispositivo)
flutter run
```

> El saldo inicial del usuario es **COP $500.000** y los datos son locales (sin backend).

---

## Cómo correr los tests

```bash
flutter test
```

Cobertura actual:

| Archivo | Casos |
|---|---|
| `portfolio_provider_test.dart` | 20 tests — lógica de suscripción y cancelación |
| `transactions_history_test.dart` | 7 tests — historial y ordenamiento |
| `validators_test.dart` | 10 tests — validación de montos |
| `currency_formatter_test.dart` | 11 tests — formato de moneda `es_CO` |
| `currency_input_formatter_test.dart` | 8 tests — input de moneda |
| `date_formatter_test.dart` | 4 tests — formato de fechas |

---

## Demo en producción

La aplicación está desplegada en AWS S3 + CloudFront:

🔗 **URL del deploy:** https://d26pavxj11ukhg.cloudfront.net

---

## Decisiones de diseño

- **Riverpod `NotifierProvider`** sobre `StateNotifierProvider` (deprecado en Riverpod 3) para manejo de estado tipado y testeable sin boilerplate.
- **Feature-first folder structure** — cada feature agrupa su screen, widgets y lógica, facilitando escalar por dominio.
- **Datos mock en constantes locales** (`app_constants.dart`) simulando una API REST, fácilmente reemplazables por un provider con `http`/`dio`.
- **Layout adaptativo** con un único punto de quiebre en 600px: móvil usa `BottomNavigationBar` y bottom sheets nativos, web usa sidebar fijo y dialogs modales centrados.
- **`showGeneralDialog` en web** en lugar de `showDialog` para evitar conflictos de lifecycle con el wrapping de `CapturedThemes` de Flutter al cerrar modales con widgets animados.
