<div align="center">
  <img width="120" height="120" src="https://github.com/user-attachments/assets/d5bb299f-3ccc-4c73-94e6-5da0166485e5" />
  <h1>Invex Up - Prueba técnica</h1>
  <p>Gestión de fondos de inversión FPV / FIC — Flutter + AWS</p>
  <p>
    <a href="https://d26pavxj11ukhg.cloudfront.net">
      🚀 Live Demo
    </a>
  </p>
  
  <p>
    <a href="https://d26pavxj11ukhg.cloudfront.net">
      <img src="https://img.shields.io/badge/demo-live-38C8A8?style=flat-square&logo=amazonaws" alt="Live Demo"/>
    </a>
    <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=flat-square&logo=flutter" />
    <img src="https://img.shields.io/badge/Riverpod-3.x-0099CC?style=flat-square" />
    <img src="https://img.shields.io/badge/deploy-AWS_S3_+_CloudFront-FF9900?style=flat-square&logo=amazonaws" />
    <img src="https://img.shields.io/badge/tests-60_casos-brightgreen?style=flat-square" />
  </p>
 
  <img width="800" src="https://github.com/user-attachments/assets/6f3f7045-5e2c-4524-8548-85d739eebd59" />
  <img width="800" src="https://github.com/user-attachments/assets/091cb86a-7375-48bf-9266-425caede9a41" />
</div>
 
<br/>
 
> **Disclaimer:** Este repositorio no corresponde a código oficial de BTG Pactual. Únicamente corresponde a una prueba técnica personal desarrollada como parte de un proceso de selección.
 
---
 
## iOS Demo — iPhone 17 Pro (iOS 26.2)
 
[Ver video](https://github.com/user-attachments/assets/ab475beb-e5b9-40b3-8692-98abd8050f0f)
 
## Android Demo — Pixel 8 Pro (Android 16)
 
[Ver video](https://github.com/user-attachments/assets/cc9f9056-86e6-4373-ad18-ebb5acd40fe5)
 
---
 
## Funcionalidades
 
| Feature | Descripción |
|---|---|
| Fondos disponibles | Listado con filtros por categoría (FPV / FIC), shimmer loading y pull-to-refresh en estado de error |
| Suscripción | Validación de monto mínimo, saldo disponible y selección de canal de notificación (Email / SMS) |
| Cancelación | Confirmación desde el portafolio activo con reintegro inmediato de saldo |
| Portafolio | Saldo disponible, total invertido, fondos activos y gráfico de distribución (barra segmentada + dona) |
| Historial | Lista cronológica de transacciones con filtros por tipo (Suscripciones / Cancelaciones) |
| Errores | Feedback visual para saldo insuficiente y monto por debajo del mínimo |
| Responsivo | Layout adaptativo: `BottomNavigationBar` en móvil, sidebar fijo en web (≥ 600 px) |
| Tema | Toggle claro / oscuro desde la app bar |
 
---
 
## Stack técnico
 
| Capa | Tecnología |
|---|---|
| Framework | Flutter 3.41 |
| Estado | Riverpod 3 (`NotifierProvider`) |
| Navegación | `IndexedStack` |
| Gráficos | fl_chart |
| Fuentes | Google Fonts — Inter |
| Moneda | `intl` (locale `es_CO`) |
| Tests | flutter_test |
| Deploy | AWS S3 + CloudFront |
| CI/CD | GitHub Actions |
 
---
 
## Arquitectura
 
El proyecto sigue una estructura **feature-first** donde cada dominio agrupa su pantalla, widgets y lógica. Los providers globales viven fuera de features para ser consumidos transversalmente.
 
```
lib/
├── core/
│   ├── theme/          # AppTheme, colores, tipografía
│   └── utils/          # CurrencyFormatter, DateFormatter, validadores
├── data/
│   └── models/         # Fund, Transaction, enums (FundCategory, NotificationMethod)
├── features/
│   ├── funds/          # FundsScreen + widgets (FundCard, FilterChips, ShimmerList)
│   ├── portfolio/      # PortfolioScreen + DistributionChart
│   ├── transactions/   # TransactionsScreen + filtros
│   └── home/           # NavigationShell (móvil + web)
├── providers/          # portfolioProvider, fundsProvider, tabProvider
└── shared/
    └── widgets/        # AppBar, EmptyState, StaggeredItem, ErrorRetry
```
 
**Flujo de datos:**
 
```
UI → Provider (NotifierProvider) → Repository → Mock Data (app_constants.dart)
```
 
Los datos mock en `app_constants.dart` simulan una API REST y son reemplazables por un provider con `http` / `dio` sin tocar la UI.
 
---
 
## Correr localmente
 
### Requisitos
 
- Flutter 3.x (`flutter --version`)
- Chrome para web, o emulador / dispositivo físico
 
```bash
# 1. Clonar
git clone https://github.com/teo2823/coding_challenge_mateot.git
cd coding_challenge_mateot
 
# 2. Instalar dependencias
flutter pub get
 
# 3. Web
flutter run -d chrome
 
# 4. Móvil
flutter run
```
 
> Saldo inicial: **COP $500.000** — datos locales, sin backend.
 
---
 
## Tests
 
```bash
flutter test
```
 
| Archivo | Casos | Cobertura |
|---|---|---|
| `portfolio_provider_test.dart` | 20 | Suscripción, cancelación, validaciones de saldo |
| `transactions_history_test.dart` | 7 | Historial, ordenamiento cronológico |
| `validators_test.dart` | 10 | Montos mínimos, saldo insuficiente |
| `currency_formatter_test.dart` | 11 | Formato COP con locale `es_CO` |
| `currency_input_formatter_test.dart` | 8 | Input de moneda en tiempo real |
| `date_formatter_test.dart` | 4 | Formato de fechas relativas y absolutas |
| **Total** | **60** | |
 
---
 
## Demo en producción
 
La aplicación está desplegada en AWS S3 + CloudFront:
 
🔗 **URL del deploy:** https://d26pavxj11ukhg.cloudfront.net
 
---
 
## CI/CD — Redespliegue automático

Cada push a `main` dispara el workflow de GitHub Actions que despliega automáticamente a producción:

```
push → main → GitHub Actions → flutter build web → aws s3 sync → CloudFront invalidation
```

El workflow (`.github/workflows/deploy.yml`) ejecuta los siguientes pasos:

1. **Build** — `flutter build web --release`
2. **Deploy a S3** — sincroniza `build/web/` con el bucket `invex-up-app`, con cache-control optimizado (`max-age` largo para assets estáticos, `no-cache` para `index.html`)
3. **Invalidación de CloudFront** — limpia el caché CDN para que los cambios sean inmediatos

Las credenciales de AWS se inyectan como secrets de GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) sin quedar expuestas en el repositorio.

---

## Decisiones técnicas
 
**`NotifierProvider` sobre `StateNotifierProvider`** — la API de Riverpod 3 unifica el patrón en una sola clase con estado mutable tipado, eliminando el boilerplate del `state = state.copyWith(...)` repetitivo.
 
**`showGeneralDialog` en web** — reemplaza `showDialog` para evitar conflictos de lifecycle con `CapturedThemes` de Flutter al cerrar modales con widgets animados en el contexto web.
 
**Layout con un único breakpoint en 600 px** — mantiene la lógica adaptativa simple y predecible: por debajo usa bottom sheets y nav bar nativa; por encima, sidebar fijo y dialogs modales centrados.
 
**Mock como capa de datos intercambiable** — `app_constants.dart` actúa como datasource local con la misma interfaz que tendría un repositorio remoto, lo que permite migrar a una API real con un cambio mínimo.
