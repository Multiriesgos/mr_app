import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil y ajustes'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _UserHeader(user: user),
          const SizedBox(height: 8),
          const Divider(indent: 16, endIndent: 16),
          _SectionTitle('Apariencia'),
          _ThemeTile(),
          const Divider(indent: 16, endIndent: 16),
          _SectionTitle('Seguridad'),
          _BiometricsTile(),
          const Divider(indent: 16, endIndent: 16),
          _SectionTitle('Información'),
          _AppVersionTile(),
          _PrivacyPolicyTile(),
          const Divider(indent: 16, endIndent: 16),
          _LogoutTile(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Secciones ────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ─── Cabecera de usuario ──────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: const Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          if (user != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.name as String,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user!.documentNumber as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (user!.email != null)
                  Text(
                    user!.email as String,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Toggle modo oscuro ───────────────────────────────────────────────────────

class _ThemeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeModeProvider);
    final mode = themeAsync.valueOrNull ?? ThemeMode.system;

    return ListTile(
      leading: Icon(
        mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
      ),
      title: const Text('Modo oscuro'),
      subtitle: Text(_modeLabel(mode)),
      trailing: DropdownButton<ThemeMode>(
        value: mode,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(8),
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('Automático'),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text('Claro'),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text('Oscuro'),
          ),
        ],
        onChanged: (m) {
          if (m != null) {
            ref.read(themeModeProvider.notifier).setMode(m);
          }
        },
      ),
    );
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'Igual al sistema',
        ThemeMode.light => 'Siempre claro',
        ThemeMode.dark => 'Siempre oscuro',
      };
}

// ─── Toggle biometría ────────────────────────────────────────────────────────

class _BiometricsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometrics = ref.watch(biometricsServiceProvider);
    final enabledAsync = ref.watch(biometricsEnabledProvider);
    final enabled = enabledAsync.valueOrNull ?? false;

    return FutureBuilder<BiometricAvailability>(
      future: biometrics.checkAvailability(),
      builder: (context, snap) {
        final availability =
            snap.data ?? BiometricAvailability.notAvailable;
        final isAvailable = availability == BiometricAvailability.available;

        return ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Bloqueo biométrico'),
          subtitle: Text(
            !isAvailable
                ? 'No disponible en este dispositivo'
                : enabled
                    ? 'Se pedirá al reabrir la app'
                    : 'Desactivado',
          ),
          trailing: Switch(
            value: enabled && isAvailable,
            onChanged: isAvailable
                ? (val) async {
                    if (val) {
                      // Verificar antes de activar
                      final ok = await biometrics.authenticate(
                        reason: 'Activa el bloqueo biométrico',
                      );
                      if (!ok) return;
                    }
                    await ref
                        .read(biometricsEnabledProvider.notifier)
                        .toggle(val);
                  }
                : null,
          ),
        );
      },
    );
  }
}

// ─── Versión de app ───────────────────────────────────────────────────────────

class _AppVersionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Versión'),
          trailing: Text(
            info != null
                ? '${info.version}+${info.buildNumber}'
                : '—',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}

// ─── Política de privacidad ───────────────────────────────────────────────────

class _PrivacyPolicyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: const Text('Política de privacidad'),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => launchUrl(
        Uri.parse(ExternalLinks.privacyPolicy),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}

// ─── Cerrar sesión ────────────────────────────────────────────────────────────

class _LogoutTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout_outlined, color: Colors.red),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _showLogoutDialog(context, ref),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar salida'),
        content: const Text('¿Está seguro de que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child:
                const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
