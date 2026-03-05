# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**mr_app** (Multimate) — Cliente Multiriesgos, a fintech/banking Flutter application for insurance services. Package: `com.multiriesgos.multimate`. Supports Android, iOS, Web, Windows, macOS, and Linux.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run in debug mode
flutter run --release    # Run in release mode
flutter build apk        # Build Android APK
flutter build aab        # Build Android App Bundle
flutter analyze          # Run linter/static analysis
flutter test             # Run tests
flutter test test/widget_test.dart  # Run single test file
```

Android signing requires a `key.properties` file (not in repo) referenced by `android/app/build.gradle`.

## Architecture

### Navigation
- **GoRouter** (`go_router` v14.2.7) configured in `lib/theme/nav/nav.dart`
- Named routes with `FFRoute` extensions; initial location: `/`
- Note: `get` package is also a dependency but GoRouter is the primary router

### State Management
- Manual `setState()` with `StatefulWidget` — no framework (Provider, Bloc, etc.)
- `flutter_secure_storage` for encrypted credential persistence
- `get_storage` / `shared_preferences` for general key-value storage

### API Layer
- `lib/services/webservice.dart` — HTTP client with generic `Resource<T>` pattern
- Methods: `load<T>()`, `find<T>()`, `loadCab<T>()`
- Base URL: `https://secure.multiriesgos.com`
- JSON parsed with `jsonDecode` (no code-gen serialization)

### Theme System
- `lib/theme/fintech_theme.dart` — `FinTechTheme` abstract base with `LightModeTheme`
- `lib/app_theme.dart` — additional theme config
- `GoogleFonts` integration; custom color schemes in `lib/models/color_schemes.g.dart`

### Responsive Design
- `lib/ui/` — `ScreenTypeLayout` (mobile/tablet), `OrientationLayout` (portrait/landscape), `ResponsiveBuilder`
- `flutter_screenutil` for responsive sizing

### Localization
- `lib/theme/internationalization.dart` — `FFLocalizations` custom implementation
- Currently English only; translation map structure ready for expansion

## Code Organization

- **Feature-per-folder**: each feature (e.g., `sign_in/`, `home/`, `my_cards/`) has its own directory with `*_widget.dart` files
- `lib/components/` — reusable dialog/modal widgets
- `lib/models/` — data models (`storage_item.dart`, `cab_item.dart`, `ren_item.dart`)
- `lib/services/` — business logic (storage, HTTP)
- `lib/utils/` — constants, helpers, UI utilities
- `lib/views/` — responsive view variants (small/large/tablet)
- `lib/widgets/` — shared reusable widgets

## Key Patterns

- Authentication: document number + birth date (DD/MM/YYYY), OTP verification, secure storage
- Widget naming: `*_widget.dart` for page widgets, `*_model.dart` for models
- Entry point: `lib/main.dart` — splash screen → login → home dashboard
- Custom fonts in `assets/fonts/` (WorkSans, Roboto)
- Animations via `flutter_animate`, `animations`, Lottie, and Rive files
