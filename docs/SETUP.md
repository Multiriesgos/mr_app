# Developer Setup — mr_app (Multimate / Multiriesgos)

## Prerequisites

- Flutter SDK (stable channel, >=3.35.0)
- Dart SDK >=3.9.0
- Android Studio or VS Code with Flutter/Dart plugins
- Xcode 15+ (for iOS builds)
- CocoaPods (for iOS builds)

## First-time setup

```bash
flutter pub get
```

## Secret files

The following files are **NOT** in the repository. Request them from the team lead and place them at the paths below:

| File | Path in repo | Where to get it |
|------|-------------|-----------------|
| Android keystore | `multiriesgos.jks` (repo root) | `~/.mr-secrets/multiriesgos.jks` |
| Android key properties | `android/key.properties` | `~/.mr-secrets/key.properties` |
| Google Play service account | `multiriesgos-489400-8b33d1d22288.json` (repo root) | `~/.mr-secrets/multiriesgos-489400-8b33d1d22288.json` |
| iOS provisioning profile | `Multiriesgos_AppStore.mobileprovision` (repo root) | Managed by Codemagic / App Store Connect |

> These files are listed in `.gitignore` and must **never** be committed.

Recommended local layout:
```
~/.mr-secrets/
├── multiriesgos.jks
├── key.properties          # points storeFile to ~/.mr-secrets/multiriesgos.jks
└── multiriesgos-489400-8b33d1d22288.json
```

Then create symlinks (or copy) into the repo root / android/ before building:
```bash
ln -s ~/.mr-secrets/multiriesgos.jks ./multiriesgos.jks
ln -s ~/.mr-secrets/key.properties ./android/key.properties
ln -s ~/.mr-secrets/multiriesgos-489400-8b33d1d22288.json ./multiriesgos-489400-8b33d1d22288.json
```

## API key

The `MR_API_KEY` is injected at build time via `--dart-define`. It is **never** hardcoded in source.

### Running locally

```bash
flutter run --dart-define=MR_API_KEY=<your_key>
```

### VS Code (`launch.json`)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "mr_app (debug)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=MR_API_KEY=${env:MR_API_KEY}"]
    }
  ]
}
```

Set `MR_API_KEY` in your shell profile (`~/.zshrc` or `~/.bashrc`):
```bash
export MR_API_KEY="<key_from_team_lead>"
```

### Android Studio

In `Run > Edit Configurations > Additional run args`:
```
--dart-define=MR_API_KEY=<your_key>
```

### CI (Codemagic)

The key is stored as an encrypted environment variable `MR_API_KEY` in Codemagic and injected automatically by the build scripts. No manual action required.

## Running tests

```bash
flutter test                        # Unit + widget tests
flutter test integration_test/      # Integration tests (requires device/emulator)
flutter analyze                     # Static analysis
```

## Building for release

```bash
# Android AAB
flutter build aab --release --dart-define=MR_API_KEY=$MR_API_KEY

# iOS IPA
flutter build ipa --release --dart-define=MR_API_KEY=$MR_API_KEY
```

Release builds are normally triggered automatically by Codemagic on push to `main`.
See `codemagic.yaml` for workflow details.
