import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key, this.user, this.onTabChange});

  final User? user;
  final ValueChanged<int>? onTabChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final name = user?.name ?? '';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            Text(
              name.toUpperCase(),
              maxLines: 2,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cs.outlineVariant),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Semantics(
              label: 'Ver perfil',
              button: true,
              child: GestureDetector(
                onTap: () => onTabChange?.call(3),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials(name),
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Semantics(
            label: 'Cerrar sesión',
            button: true,
            child: IconButton(
              icon: Icon(Icons.logout_outlined, color: cs.primary),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _HomeContent(onTabChange: onTabChange),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({this.onTabChange});

  final ValueChanged<int>? onTabChange;

  Future<void> _call() async {
    final uri = Uri.parse(ExternalLinks.callCenter);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openCotizador() async {
    final uri = Uri.parse(ExternalLinks.cotizador);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCESO RÁPIDO',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _QuickActionCard(
                icon: Icons.description_outlined,
                label: 'Mis pólizas',
                color: cs.primary,
                onTap: () => onTabChange?.call(2),
              ),
              _QuickActionCard(
                icon: Icons.credit_card_outlined,
                label: 'Mi carnet',
                color: AppColors.info,
                onTap: () => onTabChange?.call(1),
              ),
              _QuickActionCard(
                icon: Icons.phone_outlined,
                label: 'Llamar soporte',
                color: AppColors.success,
                onTap: _call,
              ),
              _QuickActionCard(
                icon: Icons.calculate_outlined,
                label: 'Cotizar en línea',
                color: AppColors.accent,
                onTap: _openCotizador,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SupportCard(onCall: _call),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onCall});

  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_outlined, color: cs.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centro de atención',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lunes a viernes · 8:00 – 17:00',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Llamar al centro de atención',
            button: true,
            child: IconButton(
              onPressed: onCall,
              icon: Icon(Icons.phone_outlined, color: cs.primary, size: 22),
              tooltip: 'Llamar',
            ),
          ),
        ],
      ),
    );
  }
}
