import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sidebarBg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => context.pop()),
              _LastUpdatedBar(
                lastUpdated: ref
                    .watch(productsProvider.notifier)
                    .lastUpdated,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(productsProvider.notifier).reload(),
                  color: AppColors.primary,
                  child: state.when(
                    skipLoadingOnReload: true,
                    loading: () => const SkeletonProductList(),
                    error: (e, _) => _ErrorView(
                      message: e is AppException
                          ? e.message
                          : 'Sin conexión. Revisá tu internet e intentá de nuevo.',
                      onRetry: () =>
                          ref.read(productsProvider.notifier).reload(),
                    ),
                    data: (products) => products.isEmpty
                        ? const _EmptyView()
                        : _ProductList(products: products),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          if (canPop)
            Semantics(
              label: 'Volver',
              button: true,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_sharp, color: Colors.white, size: 24),
                tooltip: 'Volver',
              ),
            )
          else
            const SizedBox(width: 48),
          const Expanded(
            child: Text(
              'Mis pólizas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _LastUpdatedBar extends StatelessWidget {
  const _LastUpdatedBar({required this.lastUpdated});
  final DateTime? lastUpdated;

  String _label() {
    if (lastUpdated == null) return '';
    final diff = DateTime.now().difference(lastUpdated!);
    if (diff.inSeconds < 60) return 'Actualizado hace un momento';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Actualizado hace $m ${m == 1 ? "min" : "min"}';
    }
    final h = diff.inHours;
    return 'Actualizado hace $h ${h == 1 ? "hora" : "horas"}';
  }

  @override
  Widget build(BuildContext context) {
    if (lastUpdated == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Text(
        _label(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products});
  final List<Product> products;

  static int _urgencyScore(Product p) {
    if (p.fechaRenovacion == null) return 3;
    final days = p.fechaRenovacion!.difference(DateTime.now()).inDays;
    if (days < 0) return 0;
    if (days <= 30) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...products]
      ..sort((a, b) {
        final cmp = _urgencyScore(a).compareTo(_urgencyScore(b));
        if (cmp != 0) return cmp;
        if (a.fechaRenovacion != null && b.fechaRenovacion != null) {
          return a.fechaRenovacion!.compareTo(b.fechaRenovacion!);
        }
        return 0;
      });
    return RepaintBoundary(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sorted.length,
        itemBuilder: (context, i) => _PolicyCard(product: sorted[i]),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ramoColor = _colorForRamo(product.ramo);
    final ramoIcon = _iconForRamo(product.ramo);
    final statusWidget = _buildStatusChip(context, product.fechaRenovacion);
    final dateStr = product.fechaRenovacion != null
        ? DateFormat('dd/MM/yyyy').format(product.fechaRenovacion!)
        : null;

    return Semantics(
      label: '${product.ramo}, ${product.tipoSeguro}'
          '${product.placa.isNotEmpty ? ", placa ${product.placa}" : ""}'
          '${dateStr != null ? ", renovación $dateStr" : ""}',
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: AppColors.shadowSm,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(
              '/home/products/${product.idRen}',
              extra: product,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ramoColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(ramoIcon, color: ramoColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.ramo,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (statusWidget != null) ...[
                              const SizedBox(width: 8),
                              statusWidget,
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.tipoSeguro,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                        if (product.placa.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.placa,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                        if (dateStr != null) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Renueva: $dateStr',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ],
                        if (product.fechaRenovacion != null &&
                            product.fechaRenovacion!
                                    .difference(DateTime.now())
                                    .inDays <=
                                30) ...[
                          const SizedBox(height: 6),
                          _RenovarChip(
                            expired: product.fechaRenovacion!
                                .isBefore(DateTime.now()),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForRamo(String ramo) {
    final r = ramo.toLowerCase();
    if (r.contains('auto') || r.contains('veh')) return AppColors.info;
    if (r.contains('vida')) return AppColors.success;
    if (r.contains('salud') || r.contains('medic')) return AppColors.statSuccess;
    if (r.contains('incendio') || r.contains('hogar')) return AppColors.warning;
    return AppColors.primary;
  }

  IconData _iconForRamo(String ramo) {
    final r = ramo.toLowerCase();
    if (r.contains('auto') || r.contains('veh')) return Icons.directions_car_outlined;
    if (r.contains('vida')) return Icons.favorite_border;
    if (r.contains('salud') || r.contains('medic')) return Icons.medical_services_outlined;
    if (r.contains('incendio') || r.contains('hogar')) return Icons.home_outlined;
    return Icons.description_outlined;
  }

  Widget? _buildStatusChip(BuildContext context, DateTime? date) {
    if (date == null) return null;
    final days = date.difference(DateTime.now()).inDays;
    if (days < 0) {
      return const _StatusChip(
        label: 'Vencida',
        color: AppColors.errorDark,
        bg: AppColors.errorBg,
      );
    }
    if (days <= 30) {
      return _StatusChip(
        label: 'Vence en ${days}d',
        color: AppColors.warningDark,
        bg: AppColors.warningBg,
      );
    }
    return const _StatusChip(
      label: 'Vigente',
      color: AppColors.successDark,
      bg: AppColors.successBg,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _RenovarChip extends StatelessWidget {
  const _RenovarChip({required this.expired});
  final bool expired;

  Future<void> _launch() async {
    final uri = Uri.parse(ExternalLinks.cotizador);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = expired ? AppColors.errorDark : AppColors.warningDark;
    final bg = expired ? AppColors.errorBg : AppColors.warningBg;
    return Semantics(
      label: 'Cotizar renovación',
      button: true,
      child: GestureDetector(
        onTap: _launch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.autorenew_rounded, size: 11, color: color),
              const SizedBox(width: 3),
              Text(
                'Renovar',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.policy_outlined,
                      size: 44,
                      color: cs.primary.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sin pólizas activas',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No encontramos pólizas vigentes\nasociadas a tu documento.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(ExternalLinks.cotizador),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    label: const Text('Cotizar en línea'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_outlined,
                      size: 44,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No se pudo cargar',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.tonal(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
