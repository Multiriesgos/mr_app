# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**mr_app** (Multimate) — Cliente Multiriesgos, fintech/insurance Flutter app.
- Package Android: `multiriesgos.multimate.app`
- Package iOS: `com.multiriesgos.multimate`
- Active platforms: **Android + iOS only**. Windows/macOS/Linux/web are default scaffolds, not deployed.
- Version: `2.1.1+7` (current)

## Common Commands

```bash
flutter pub get                                        # Install dependencies
flutter run                                            # Debug mode
flutter run --release --dart-define=MR_API_KEY=xxx     # Release mode with API key
flutter build aab --dart-define=MR_API_KEY=xxx         # Android App Bundle (Play Store)
flutter build apk --split-per-abi --dart-define=...    # APKs split by ABI (testing)
flutter build ipa --dart-define=MR_API_KEY=xxx         # iOS (requires Mac + signing)
flutter analyze                                        # Linter (very_good_analysis)
flutter test                                           # Unit tests
flutter test integration_test/                         # Integration tests (needs device)
bash scripts/install-hooks.sh                          # Install pre-commit hook (once per clone)
```

Android signing: `key.properties` in `~/.mr-secrets/` (not in repo).
API key injected via `--dart-define MR_API_KEY=...` — never hardcoded.

## Architecture (Clean Architecture — implemented)

```
lib/
├── core/
│   ├── auth/            (BiometricsService — local_auth wrapper)
│   ├── config/          (ExternalLinks)
│   ├── di/              (settingsProviders: themeModeProvider, biometricsEnabledProvider)
│   ├── error/           (AppException: NetworkException, ServerException, AuthException)
│   ├── logging/         (appLogger — Talker singleton, no PII)
│   ├── network/         (MrHttpClient — IOClient factory, certificate pinning structure)
│   ├── router/          (app_router.dart — GoRouter with auth redirect guard)
│   ├── storage/         (secureStorageProvider — FlutterSecureStorage, AES-GCM + RSA-OAEP)
│   ├── theme/           (app_colors.dart — single source of truth; app_theme.dart light+dark)
│   └── widgets/         (ShimmerBox, SkeletonProductList, SkeletonProductDetail)
├── features/
│   ├── auth/            (Splash → Login — data/domain/presentation, Riverpod AsyncNotifier)
│   ├── home/            (HomeScreen with BottomNav: HomeTab, BenefitCard, Products, Profile)
│   ├── products/        (Mis Productos + Detalle — GoRouter /home/products/:id)
│   ├── benefits/        (Carnet digital + Medic + Club Ahorro)
│   └── notifications/   (Scaffold — stub, pendiente Firebase)
└── main.dart            (~75 lines: HttpOverrides + ProviderScope + MyApp)
```

Each feature: `data/{datasources,models,repositories}` · `domain/{entities,repositories,usecases}` · `presentation/{providers,screens,widgets}`.

## State Management

- **Riverpod 2.x** (`flutter_riverpod ^2.6.1`, `riverpod_annotation`)
- `AsyncNotifier<T>` for async state; `StateProvider` avoided
- No `setState` except `HomeScreen._currentIndex` (BottomNav) and `SplashScreen` animation
- Key providers: `authProvider`, `productsProvider`, `productDetailProvider`, `themeModeProvider`, `biometricsEnabledProvider`

## Navigation

- **GoRouter 14.2.7** — `lib/core/router/app_router.dart`
- Auth guard: `redirect:` switch on `AuthState` (Loading → `/`, Authenticated → `/home`, Unauthenticated → `/login`)
- Routes: `/` (Splash) · `/login` · `/home` · `/home/products` · `/home/products/:id` · `/home/benefits`

## HTTP & Security

- `MrHttpClient.create()` → `IOClient` via `httpClientProvider` (Riverpod)
- Certificate pinning: **ACTIVO** — SPKI SHA-256 del intermedio Let's Encrypt R12 (`kZwN96eHtZftBWrOZUsd6cA4es80n3NzSk/XtYz2EqQ=`)
  - Android: `network_security_config.xml` — `<pin-set expiration="2027-02-28">` activo
  - iOS: `NSPinnedDomains → NSPinnedCAIdentities` en `Info.plist` activo
  - Renovar antes del **2027-02-28** si Let's Encrypt cambia su intermedio (muy infrecuente)
  - Instrucciones de renovación en `lib/core/network/mr_http_client.dart`
- `badCertificateCallback → false` rechaza todo cert con fallo de validación del sistema
- R8 + minify + shrinkResources enabled in Android release

## Theme System

- `lib/core/theme/app_colors.dart` — **single source of truth** (static constants + ColorScheme factories)
- `lib/core/theme/app_theme.dart` — `AppTheme.light` and `AppTheme.dark` (Material 3)
- `themeModeProvider` (AsyncNotifier) — persisted in `flutter_secure_storage`
- All active screens use `Theme.of(context)` / `AppColors`. `FinTechTheme` is a legacy compatibility shim; do not use it in new code.

## Localization

- `flutter gen-l10n` — `lib/l10n/app_es.arb` (primary) + `app_en.arb`
- UI language: Spanish (es)

## Biometrics (Fase 5)

- `local_auth ^2.3.0` — `BiometricsService` in `lib/core/auth/biometrics_service.dart`
- Re-auth on app resume when enabled: `HomeScreen` uses `WidgetsBindingObserver`
- Toggle persisted in SecureStorage via `biometricsEnabledProvider`
- Android: `USE_BIOMETRIC` + `USE_FINGERPRINT` permissions
- iOS: `NSFaceIDUsageDescription` in Info.plist

## Push Notifications (Fase 5 — scaffold pendiente Firebase)

- Interface: `lib/features/notifications/domain/notification_service.dart`
- Current: `NotificationServiceStub` (noop)
- To activate: see 7-step instructions in the interface docstring
- Steps: create Firebase project → add `firebase_core ^3.x` + `firebase_messaging ^15.x` → replace stub

## CI/CD (Codemagic)

Three workflows in `codemagic.yaml`:
- `pr-validation`: Linux · `flutter analyze --fatal-warnings` + `flutter test --coverage` on every PR to `main`
- `ios-release`: mac_mini_m2 → TestFlight (App Store Connect API)
- `android-release`: linux_x2 → AAB to Google Play `internal` + APK split per ABI as artifact

## Accessibility (Fase 6)

- All interactive `InkWell` + icon-only buttons wrapped in `Semantics(label:..., button: true)`
- `RepaintBoundary` around `ListView.builder` in ProductsScreen
- Note: `AppColors.textMuted` (#718096) has ~3.9:1 contrast ratio — compliant for large text only (≥18px or ≥14px bold). Use `Theme.of(context).colorScheme.onSurfaceVariant` for secondary text in tight contexts.

## Assets

Custom fonts: `WorkSans` (Regular/Medium/SemiBold/Bold), `Roboto` (Regular/Medium/Bold) — in `assets/fonts/`.
Images in `assets/images/` (PNG/JPG). For future network images use `cached_network_image`.

## Legacy Files (do not modify, scheduled for eventual deletion)

- `lib/theme/fintech_theme.dart` — compatibility shim only; all new code uses `AppColors`/`Theme.of`
- `lib/theme/fintech_util.dart`, `lib/theme/fintech_widgets.dart` — no active usages
