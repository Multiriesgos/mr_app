import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/di/settings_providers.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _store[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_store);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _store.clear();
  }
}

void main() {
  late ProviderContainer container;

  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
    container = ProviderContainer.test();
  });

  group('themeModeProvider', () {
    test('devuelve ThemeMode.light por defecto sin valor guardado', () async {
      final mode = await container.read(themeModeProvider.future);
      expect(mode, ThemeMode.light);
    });

    test('setMode persiste dark y actualiza el estado', () async {
      await container.read(themeModeProvider.future);

      await container.read(themeModeProvider.notifier).setMode(
            ThemeMode.dark,
          );

      expect(container.read(themeModeProvider).value, ThemeMode.dark);
    });

    test('un provider nuevo lee el valor persistido previamente', () async {
      await container.read(themeModeProvider.future);
      await container.read(themeModeProvider.notifier).setMode(
            ThemeMode.dark,
          );

      final secondContainer = ProviderContainer.test();
      final mode = await secondContainer.read(themeModeProvider.future);

      expect(mode, ThemeMode.dark);
    });

    test('setMode con system persiste y refleja el estado', () async {
      await container.read(themeModeProvider.future);

      await container.read(themeModeProvider.notifier).setMode(
            ThemeMode.system,
          );

      expect(container.read(themeModeProvider).value, ThemeMode.system);
    });
  });

  group('biometricsEnabledProvider', () {
    test('devuelve false por defecto sin valor guardado', () async {
      final enabled = await container.read(biometricsEnabledProvider.future);
      expect(enabled, isFalse);
    });

    test('toggle(true) persiste y actualiza el estado', () async {
      await container.read(biometricsEnabledProvider.future);

      await container.read(biometricsEnabledProvider.notifier).toggle(true);

      expect(container.read(biometricsEnabledProvider).value, isTrue);
    });

    test('un provider nuevo lee el valor persistido previamente', () async {
      await container.read(biometricsEnabledProvider.future);
      await container.read(biometricsEnabledProvider.notifier).toggle(true);

      final secondContainer = ProviderContainer.test();
      final enabled = await secondContainer.read(
        biometricsEnabledProvider.future,
      );

      expect(enabled, isTrue);
    });
  });
}
