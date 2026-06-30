import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/di/settings_providers.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/app_avatar.dart';
import 'package:mr_app/core/widgets/app_logout_dialog.dart';
import 'package:mr_app/core/widgets/app_nav_bar.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
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
      appBar: const AppNavBar(
        title:   'Perfil y ajustes',
        leading: AppNavBarLeading.none,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _UserHeader(user: user),
          const SizedBox(height: AppSpacing.sm),
          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          const _SectionTitle('Apariencia'),
          _ThemeTile(),
          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          const _SectionTitle('Seguridad'),
          _BiometricsTile(),
          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          const _SectionTitle('Información'),
          _AppVersionTile(),
          if (kDebugMode) _FcmTokenTile(),
          _PrivacyPolicyTile(),
          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
          _LogoutTile(),
          const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.s04, AppSpacing.md, AppSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color:       AppColors.primary,
          fontWeight:  FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Cabecera de usuario ──────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingH,
        vertical:   AppSpacing.lg,
      ),
      child: Column(
        children: [
          AppAvatar.profile(name: name),
          if (user != null) ...[
            const SizedBox(height: AppSpacing.s04),
            Text(
              user!.name,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.s01),
            Text(
              user!.documentNumber,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (user!.email != null)
              Text(
                user!.email!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
          ],
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
      leading: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
      title:   const Text('Modo oscuro'),
      subtitle: Text(_modeLabel(mode)),
      trailing: DropdownButton<ThemeMode>(
        value:       mode,
        underline:   const SizedBox.shrink(),
        borderRadius: AppRadius.smBR,
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('Automático')),
          DropdownMenuItem(value: ThemeMode.light,  child: Text('Claro')),
          DropdownMenuItem(value: ThemeMode.dark,   child: Text('Oscuro')),
        ],
        onChanged: (m) {
          if (m != null) ref.read(themeModeProvider.notifier).setMode(m);
        },
      ),
    );
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Igual al sistema',
    ThemeMode.light  => 'Siempre claro',
    ThemeMode.dark   => 'Siempre oscuro',
  };
}

// ─── Toggle biometría ────────────────────────────────────────────────────────

class _BiometricsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometrics   = ref.watch(biometricsServiceProvider);
    final enabledAsync = ref.watch(biometricsEnabledProvider);
    final enabled      = enabledAsync.valueOrNull ?? false;

    return FutureBuilder<BiometricAvailability>(
      future: biometrics.checkAvailability(),
      builder: (context, snap) {
        final availability  = snap.data ?? BiometricAvailability.notAvailable;
        final isAvailable   = availability == BiometricAvailability.available;

        return ListTile(
          leading:  const Icon(Icons.fingerprint),
          title:    const Text('Bloqueo biométrico'),
          subtitle: Text(
            !isAvailable
                ? 'No disponible en este dispositivo'
                : enabled
                    ? 'Se pedirá al reabrir la app'
                    : 'Desactivado',
          ),
          trailing: Switch(
            value:     enabled && isAvailable,
            onChanged: isAvailable
                ? (val) async {
                    if (val) {
                      final ok = await biometrics.authenticate(
                        reason: 'Activa el bloqueo biométrico',
                      );
                      if (!ok) return;
                    }
                    await ref.read(biometricsEnabledProvider.notifier).toggle(val);
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
          leading:  const Icon(Icons.info_outline),
          title:    const Text('Versión'),
          trailing: Text(
            info != null ? '${info.version}+${info.buildNumber}' : '—',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}

// ─── Token FCM (solo debug) ───────────────────────────────────────────────────

class _FcmTokenTile extends StatefulWidget {
  @override
  State<_FcmTokenTile> createState() => _FcmTokenTileState();
}

class _FcmTokenTileState extends State<_FcmTokenTile> {
  String? _token;
  bool    _loading = true;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((t) {
      if (mounted) setState(() { _token = t; _loading = false; });
    });
  }

  Future<void> _copy() async {
    if (_token == null) return;
    await Clipboard.setData(ClipboardData(text: _token!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:  Text('Token FCM copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = _loading
        ? 'Cargando…'
        : _token == null
            ? 'No disponible'
            : '${_token!.substring(0, 12)}…${_token!.substring(_token!.length - 8)}';

    return ListTile(
      leading:  const Icon(Icons.key_outlined, color: AppColors.warning),
      title:    const Text('[DEBUG] Token FCM'),
      subtitle: Text(display, style: Theme.of(context).textTheme.bodySmall),
      trailing: _token != null
          ? IconButton(
              icon:    const Icon(Icons.copy_outlined, size: 18),
              tooltip: 'Copiar token completo',
              onPressed: _copy,
            )
          : null,
      onTap: _copy,
    );
  }
}

// ─── Política de privacidad ───────────────────────────────────────────────────

class _PrivacyPolicyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:  const Icon(Icons.privacy_tip_outlined),
      title:    const Text('Política de privacidad'),
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
      leading: const Icon(Icons.logout_outlined, color: AppColors.error),
      title:   const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
      onTap:   () => showLogoutDialog(context, ref),
    );
  }
}
