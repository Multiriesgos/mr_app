# Multimate — Cliente Multiriesgos

[![Codemagic build status](https://api.codemagic.io/apps/69aa2074f76d35ab6ae977bf/android-release/status_badge.svg)](https://codemagic.io/apps/69aa2074f76d35ab6ae977bf/android-release/latest_build)
[![iOS build](https://api.codemagic.io/apps/69aa2074f76d35ab6ae977bf/ios-release/status_badge.svg)](https://codemagic.io/apps/69aa2074f76d35ab6ae977bf/ios-release/latest_build)

App Flutter de seguros para clientes Multiriesgos. Plataformas activas: **Android + iOS**.

- **Bundle ID Android:** `multiriesgos.multimate.app`
- **Bundle ID iOS:** `com.multiriesgos.multimate`
- **Versión actual:** 2.1.0

---

## Requisitos

- Flutter SDK `>=3.35.0` (canal `stable`)
- Dart `>=3.5.1`
- Android Studio / Xcode para builds nativos

## Configuración local

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Instalar el pre-commit hook (una vez al clonar)
bash scripts/install-hooks.sh

# 3. Correr en debug (requiere --dart-define para la API key)
flutter run --dart-define=MR_API_KEY=<tu_clave_local>
```

Los secretos (keystore, service account, mobileprovision) se guardan en `~/.mr-secrets/`.
Ver `docs/SETUP.md` para el bootstrap completo.

## Comandos útiles

```bash
flutter analyze          # Lint + análisis estático
flutter test             # Tests unitarios
flutter test --coverage  # Tests con reporte de cobertura (coverage/lcov.info)
flutter build apk        # Build Android APK
flutter build aab        # Build Android App Bundle
flutter build ipa        # Build iOS IPA
```

## CI/CD

Gestionado por **Codemagic** (`codemagic.yaml`):

| Workflow | Cuándo corre | Destino |
|---|---|---|
| `pr-validation` | Cada PR hacia `main` | — |
| `ios-release` | Manual / tag | TestFlight |
| `android-release` | Manual / tag | Play Internal |

## Arquitectura

Clean Architecture + Riverpod 2.x + GoRouter. Ver `CLAUDE.md` para el detalle completo.
