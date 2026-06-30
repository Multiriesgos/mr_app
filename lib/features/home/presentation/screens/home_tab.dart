import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_motion.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/app_avatar.dart';
import 'package:mr_app/core/widgets/app_logout_dialog.dart';
import 'package:mr_app/core/widgets/app_status_badge.dart';
import 'package:mr_app/core/widgets/policy_utils.dart';
import 'package:mr_app/core/widgets/shimmer_box.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
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
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.sidebarBg,
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(
                color:       Colors.white60,
                fontSize:    12,
                fontWeight:  FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              _shortName(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color:       Colors.white,
                fontSize:    17,
                fontWeight:  FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: Colors.white12),
        ),
        actions: [
          Semantics(
            label: 'Ver perfil',
            button: true,
            child: GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); onTabChange?.call(3); },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: AppAvatar(name: name, radius: 18),
              ),
            ),
          ),
          Semantics(
            label: 'Cerrar sesión',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 22),
              tooltip: 'Cerrar sesión',
              onPressed: () => showLogoutDialog(context, ref),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final messenger = ScaffoldMessenger.of(context);
            await ref.read(productsProvider.notifier).reload();
            if (!context.mounted) return;
            final n = ref.read(productsProvider.notifier);
            if (!n.fromCache && ref.read(productsProvider).hasValue) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Pólizas actualizadas'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          color: AppColors.primary,
          child: _HomeContent(onTabChange: onTabChange),
        ),
      ),
    );
  }

  static String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (parts.length <= 2) return name.trim();
    return '${parts.first} ${parts.last}';
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

// ─── Contenido ────────────────────────────────────────────────────────────────

class _HomeContent extends ConsumerWidget {
  const _HomeContent({this.onTabChange});

  final ValueChanged<int>? onTabChange;

  Future<void> _call(String? phone) async {
    final raw = phone != null && phone.isNotEmpty ? phone : null;
    final uri = raw != null
        ? Uri.parse('tel:+503$raw')
        : Uri.parse(ExternalLinks.callCenter);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsApp(String? whatsapp) async {
    final raw = whatsapp != null && whatsapp.isNotEmpty ? whatsapp : null;
    final uri = raw != null
        ? Uri.parse('https://wa.me/503$raw')
        : Uri.parse(ExternalLinks.whatsappCenter);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openCotizador() async {
    final uri = Uri.parse(ExternalLinks.cotizador);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs            = Theme.of(context).colorScheme;
    final productsAsync = ref.watch(productsProvider);
    final renewingSoon  = _renewingSoon(productsAsync.valueOrNull);
    final products      = productsAsync.valueOrNull;
    final contact       = ref.watch(homeContactProvider).valueOrNull;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingH, AppSpacing.lg,
        AppSpacing.pagePaddingH, AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats / Skeletons ────────────────────────────────────────────
          if (productsAsync.isLoading) ...[
            _RenewalAlertsSkeleton(),
            const SizedBox(height: AppSpacing.sectionGap),
            _StatsSkeleton(),
            const SizedBox(height: AppSpacing.sectionGap),
          ] else ...[
            if (renewingSoon.isNotEmpty) ...[
              _RenewalAlertsSection(
                products: renewingSoon,
                onProductTap: (p) => context.go('/home/products/${p.idRen}'),
              ),
              const SizedBox(height: AppSpacing.cardGap),
            ],
            if (products != null && products.isNotEmpty) ...[
              _StatsRow(products: products),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
          ],

          // ── Centro de atención ───────────────────────────────────────────
          _SupportCard(
            onCall:      () => _call(contact?.phone),
            onWhatsApp:  () => _whatsApp(contact?.whatsapp),
            hasWhatsApp: contact?.hasWhatsApp ?? true,
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // ── Acceso rápido ────────────────────────────────────────────────
          Text(
            'ACCESO RÁPIDO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: [
              _QuickActionCard(
                icon:  Icons.description_outlined,
                label: 'Mis pólizas',
                color: cs.primary,
                onTap: () => onTabChange?.call(2),
              ),
              _QuickActionCard(
                icon:  Icons.credit_card_outlined,
                label: 'Mi carnet',
                color: AppColors.info,
                onTap: () => onTabChange?.call(1),
              ),
              _QuickActionCard(
                icon:  Icons.person_outline,
                label: 'Mi perfil',
                color: AppColors.success,
                onTap: () => onTabChange?.call(3),
              ),
              _QuickActionCard(
                icon:  Icons.calculate_outlined,
                label: 'Cotizar en línea',
                color: AppColors.accent,
                onTap: _openCotizador,
              ),
            ],
          ),

          if (productsAsync.hasValue && productsAsync.value!.isEmpty) ...[
            const SizedBox(height: AppSpacing.pagePaddingH),
            _NoPoliciesBanner(onCotizar: _openCotizador),
          ],
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

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final now      = DateTime.now();
    final total    = products.length;
    final vigentes = products.where((p) {
      if (p.fechaRenovacion == null) return true;
      return p.fechaRenovacion!.difference(now).inDays > 30;
    }).length;
    final proximas = products.where((p) {
      if (p.fechaRenovacion == null) return false;
      final d = p.fechaRenovacion!.difference(now).inDays;
      return d >= 0 && d <= 30;
    }).length;
    final vencidas = products.where((p) {
      if (p.fechaRenovacion == null) return false;
      return p.fechaRenovacion!.isBefore(now);
    }).length;

    return Row(
      children: [
        _StatCard(
          value: total,
          label: total == 1 ? 'Póliza' : 'Pólizas',
          color: Theme.of(context).colorScheme.primary,
          icon:  Icons.description_outlined,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          value: vigentes,
          label: 'Vigentes',
          color: AppColors.success,
          icon:  Icons.check_circle_outline,
        ),
        const SizedBox(width: AppSpacing.sm),
        if (vencidas > 0)
          _StatCard(
            value: vencidas,
            label: 'Vencidas',
            color: AppColors.error,
            icon:  Icons.error_outline,
          )
        else
          _StatCard(
            value: proximas,
            label: 'Por vencer',
            color: AppColors.statWarning,
            icon:  Icons.access_time_outlined,
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final int      value;
  final String   label;
  final Color    color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs           = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.07),
          borderRadius: AppRadius.mdBR,
          border:       Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:        color.withValues(alpha: 0.15),
                borderRadius: AppRadius.smBR,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.xs),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: reduceMotion ? Duration.zero : AppMotion.slow01,
              curve: AppMotion.entrance,
              builder: (_, animated, __) => Text(
                '$animated',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:    11,
                fontWeight:  FontWeight.w500,
                color:       cs.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 20, height: 20),
                  SizedBox(height: AppSpacing.xs),
                  ShimmerBox(width: 30, height: 16),
                  SizedBox(height: 3),
                  ShimmerBox(width: 56, height: 11),
                ],
              ),
            ),
          ),
        ],
      ],
    );
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
        const SizedBox(height: AppSpacing.s04),
        for (int i = 0; i < 2; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdBR,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: const Row(
              children: [
                ShimmerBox(width: 40, height: 40, borderRadius: 10),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: double.infinity, height: 13),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerBox(width: 100, height: 11),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                ShimmerBox(width: 64, height: 22, borderRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

// ─── Alertas de renovación ────────────────────────────────────────────────────

class _RenewalAlertsSection extends StatefulWidget {
  const _RenewalAlertsSection({
    required this.products,
    required this.onProductTap,
  });
  final List<Product>           products;
  final ValueChanged<Product>   onProductTap;

  @override
  State<_RenewalAlertsSection> createState() => _RenewalAlertsSectionState();
}

class _RenewalAlertsSectionState extends State<_RenewalAlertsSection> {
  final Set<int> _dismissed = {};

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final visible = widget.products
        .where((p) => !_dismissed.contains(p.idRen))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              size: 14,
              color: AppColors.statWarning,
            ),
            const SizedBox(width: 6),
            Text(
              'PRÓXIMAS RENOVACIONES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...visible.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Dismissible(
              key: ValueKey(p.idRen),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppSpacing.pagePaddingH),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdBR,
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.textMuted),
              ),
              onDismissed: (_) => setState(() => _dismissed.add(p.idRen)),
              child: _RenewalAlertCard(
                product: p,
                onTap:   () => widget.onProductTap(p),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RenewalAlertCard extends StatelessWidget {
  const _RenewalAlertCard({required this.product, required this.onTap});
  final Product      product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final days   = product.fechaRenovacion!.difference(now).inDays;
    final status = PolicyUtils.statusOf(product.fechaRenovacion);
    final color  = status.color;

    return Semantics(
      label: '${product.tipoSeguro}, ${status.label(days)}',
      button: true,
      child: Material(
        color:        color.withValues(alpha: 0.05),
        borderRadius: AppRadius.mdBR,
        child: InkWell(
          onTap:        onTap,
          borderRadius: AppRadius.mdBR,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdBR,
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:        color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smBR,
                  ),
                  child: Icon(Icons.event_outlined, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.tipoSeguro,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.aseguradora} · ${PolicyUtils.fmtDate(product.fechaRenovacion!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppStatusBadge(date: product.fechaRenovacion),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Quick action card ────────────────────────────────────────────────────────

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppMotion.press,
  );

  late final Animation<double> _scale = Tween<double>(begin: 1, end: 0.96)
      .animate(CurvedAnimation(parent: _press, curve: Curves.easeInOut));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label:  widget.label,
      button: true,
      child: GestureDetector(
        onTapDown:   reduceMotion ? null : (_) => _press.forward(),
        onTapUp:     (_) { if (!reduceMotion) _press.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
        onTapCancel: reduceMotion ? null : ()  => _press.reverse(),
        child: ScaleTransition(
          scale: reduceMotion ? const AlwaysStoppedAnimation(1) : _scale,
          child: Container(
            decoration: BoxDecoration(
              color:        cs.surface,
              borderRadius: AppRadius.mdBR,
              border:       Border.all(color: cs.outlineVariant),
              boxShadow:    AppColors.shadowSm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width:  60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:        widget.color.withValues(alpha: 0.10),
                    borderRadius: AppRadius.mdBR,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 30),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
  const _SupportCard({
    required this.onCall,
    required this.onWhatsApp,
    this.hasWhatsApp = true,
  });
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final bool hasWhatsApp;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        cs.surfaceContainerHighest,
        borderRadius: AppRadius.mdBR,
        border:       Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:  cs.primary.withValues(alpha: 0.10),
                  shape:  BoxShape.circle,
                ),
                child: Icon(Icons.support_agent_outlined, color: cs.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              Column(
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
                    'Lun–Vie · 8:00–17:00',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Llamar al centro de atención',
                  button: true,
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon:  Icon(Icons.phone_outlined, color: cs.primary, size: 16),
                    label: Text('Llamar', style: TextStyle(color: cs.primary)),
                    style: OutlinedButton.styleFrom(
                      side:        BorderSide(color: cs.primary.withValues(alpha: 0.4)),
                      padding:     const EdgeInsets.symmetric(vertical: 10),
                      shape:       RoundedRectangleBorder(borderRadius: AppRadius.smBR),
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              ),
              if (hasWhatsApp) ...[
                const SizedBox(width: AppSpacing.s04),
                Expanded(
                  child: Semantics(
                    label: 'Escribir por WhatsApp al centro de atención',
                    button: true,
                    child: OutlinedButton.icon(
                      onPressed: onWhatsApp,
                      icon:  const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 16),
                      label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF25D366))),
                      style: OutlinedButton.styleFrom(
                        side:        const BorderSide(color: Color(0x5525D366)),
                        padding:     const EdgeInsets.symmetric(vertical: 10),
                        shape:       RoundedRectangleBorder(borderRadius: AppRadius.smBR),
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ),
                ),
              ],
            ],
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        cs.primary.withValues(alpha: 0.05),
        borderRadius: AppRadius.mdBR,
        border:       Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:        cs.primary.withValues(alpha: 0.10),
              borderRadius: AppRadius.smBR,
            ),
            child: Icon(Icons.policy_outlined, color: cs.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.cardGap),
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
                  label:  'Cotizar una nueva póliza en línea',
                  button: true,
                  child: TextButton.icon(
                    onPressed: onCotizar,
                    icon:  const Icon(Icons.calculate_outlined, size: 16),
                    label: const Text('Cotizar en línea'),
                    style: TextButton.styleFrom(
                      padding:         EdgeInsets.zero,
                      minimumSize:     Size.zero,
                      tapTargetSize:   MaterialTapTargetSize.shrinkWrap,
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
