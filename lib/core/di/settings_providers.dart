import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_app/core/storage/secure_storage.dart';

// ─── ThemeMode ───────────────────────────────────────────────────────────────

class _ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _key = 'settings_theme_mode';

  @override
  Future<ThemeMode> build() async {
    final val = await ref.watch(secureStorageProvider).read(key: _key);
    return switch (val) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    await ref.read(secureStorageProvider).write(
          key: _key,
          value: switch (mode) {
            ThemeMode.light => 'light',
            ThemeMode.dark => 'dark',
            ThemeMode.system => 'system',
          },
        );
    state = AsyncData(mode);
  }
}

final themeModeProvider =
    AsyncNotifierProvider<_ThemeModeNotifier, ThemeMode>(
  _ThemeModeNotifier.new,
);

// ─── Biometría ───────────────────────────────────────────────────────────────

class _BiometricsNotifier extends AsyncNotifier<bool> {
  static const _key = 'settings_biometrics_enabled';

  @override
  Future<bool> build() async {
    final val = await ref.watch(secureStorageProvider).read(key: _key);
    return val == 'true';
  }

  Future<void> toggle(bool value) async {
    await ref.read(secureStorageProvider).write(
          key: _key,
          value: value.toString(),
        );
    state = AsyncData(value);
  }
}

final biometricsEnabledProvider =
    AsyncNotifierProvider<_BiometricsNotifier, bool>(
  _BiometricsNotifier.new,
);
