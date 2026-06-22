import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/widgets/shimmer_box.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key, this.user, this.onTabChange});

  final User? user;
  final ValueChanged<int>? onTabChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            Text(
              _shortName(name).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.white12),
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
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: Colors.white,
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
              icon: const Icon(Icons.logout_outlined, color: Colors.white),
              tooltip: 'Cerrar sesión',
              onPressed: () => _showLogoutDialog(context, ref),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(productsProvider.notifier).reload(),
          color: AppColors.primary,
          child: _HomeContent(onTabChange: onTabChange),
        ),
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout_outlined, color: AppColors.error, size: 32),
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a ingresar tus credenciales.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  static String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (parts.length <= 2) return name.trim();
    return '${parts.first} ${parts.last}';
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ─── Contenido principal ──────────────────────────────────────────────────────

class _HomeContent extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final productsAsync = ref.watch(productsProvider);

    final renewingSoon = _renewingSoon(productsAsync.valueOrNull);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productsAsync.isLoading) ...[
            _RenewalAlertsSkeleton(),
            const SizedBox(height: 28),
          ] else if (renewingSoon.isNotEmpty) ...[
            _RenewalAlertsSection(
              products: renewingSoon,
              onProductTap: (p) => context.go('/home/products/${p.idRen}'),
            ),
            const SizedBox(height: 28),
          ],
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
                icon: Icons.person_outline,
                label: 'Mi perfil',
                color: AppColors.success,
                onTap: () => onTabChange?.call(3),
              ),
              _QuickActionCard(
                icon: Icons.calculate_outlined,
                label: 'Cotizar en línea',
                color: AppColors.accent,
                onTap: _openCotizador,
              ),
            ],
          ),
          if (productsAsync.hasValue && productsAsync.value!.isEmpty) ...[
            const SizedBox(height: 20),
            _NoPoliciesBanner(onCotizar: _openCotizador),
          ],
          const SizedBox(height: 28),
          _SupportCard(onCall: _call),
        ],
      ),
    );
  }

  static List<Product> _renewingSoon(List<Product>? products) {
    if (products == null) return [];
    final now = DateTime.now();
    final filtered = products.where((p) {
      if (p.fechaRenovacion == null) return false;
      final diff = p.fechaRenovacion!.difference(now).inDays;
      return diff >= -7 && diff <= 30;
    }).toList()
      ..sort((a, b) => a.fechaRenovacion!.compareTo(b.fechaRenovacion!));
    return filtered;
  }
}

// ─── Skeleton renovaciones ────────────────────────────────────────────────────

class _RenewalAlertsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(width: 180, height: 12),
        const SizedBox(height: 12),
        for (int i = 0; i < 2; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: const Row(
              children: [
                ShimmerBox(width: 40, height: 40, borderRadius: 10),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: double.infinity, height: 13),
                      SizedBox(height: 6),
                      ShimmerBox(width: 100, height: 11),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                ShimmerBox(width: 60, height: 22, borderRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ─── Alertas de renovación ────────────────────────────────────────────────────

class _RenewalAlertsSection extends StatelessWidget {
  const _RenewalAlertsSection({
    required this.products,
    required this.onProductTap,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              size: 15,
              color: AppColors.warning,
            ),
            const SizedBox(width: 6),
            Text(
              'PRÓXIMAS RENOVACIONES',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...products.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RenewalAlertCard(
              product: p,
              onTap: () => onProductTap(p),
            ),
          ),
        ),
      ],
    );
  }
}

class _RenewalAlertCard extends StatelessWidget {
  const _RenewalAlertCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = product.fechaRenovacion!.difference(now).inDays;
    final urgency = _Urgency.of(diff);
    final color = urgency.color;

    return Semantics(
      label: '${product.tipoSeguro}, ${urgency.label(diff)}',
      button: true,
      child: Material(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event_outlined, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.tipoSeguro,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.aseguradora,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    urgency.label(diff),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Urgencia ─────────────────────────────────────────────────────────────────

enum _Urgency {
  expired,
  critical,
  warning,
  upcoming;

  static _Urgency of(int days) {
    if (days < 0) return _Urgency.expired;
    if (days <= 7) return _Urgency.critical;
    if (days <= 15) return _Urgency.warning;
    return _Urgency.upcoming;
  }

  Color get color => switch (this) {
        _Urgency.expired => AppColors.error,
        _Urgency.critical => AppColors.error,
        _Urgency.warning => AppColors.warning,
        _Urgency.upcoming => AppColors.info,
      };

  String label(int days) => switch (this) {
        _Urgency.expired =>
          'Vencida hace ${(-days) == 1 ? "1 día" : "${-days} días"}',
        _Urgency.critical =>
          days == 0 ? 'Vence hoy' : 'Vence en ${days == 1 ? "1 día" : "$days días"}',
        _Urgency.warning => 'Vence en $days días',
        _Urgency.upcoming => 'Vence en $days días',
      };
}

// ─── Quick action card ────────────────────────────────────────────────────────

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
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
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

// ─── Support card ─────────────────────────────────────────────────────────────

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

// ─── Banner sin pólizas ───────────────────────────────────────────────────────

class _NoPoliciesBanner extends StatelessWidget {
  const _NoPoliciesBanner({required this.onCotizar});
  final VoidCallback onCotizar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.policy_outlined, color: cs.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin pólizas activas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'No encontramos pólizas vigentes asociadas a tu documento.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: 'Cotizar una nueva póliza en línea',
                  button: true,
                  child: TextButton.icon(
                    onPressed: onCotizar,
                    icon: const Icon(Icons.calculate_outlined, size: 16),
                    label: const Text('Cotizar en línea'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
