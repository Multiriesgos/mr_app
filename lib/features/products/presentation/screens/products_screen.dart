import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => context.pop()),
            Expanded(
              child: state.when(
                loading: () => const SkeletonProductList(),
                error: (e, _) => _ErrorView(
                  message: e is AppException
                      ? e.message
                      : 'Error inesperado. Por favor reintente.',
                  onRetry: () => ref.read(productsProvider.notifier).reload(),
                ),
                data: (products) => products.isEmpty
                    ? const _EmptyView()
                    : _ProductList(products: products),
              ),
            ),
          ],
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

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: products.length,
        itemBuilder: (context, i) => _PolicyCard(product: products[i]),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_books_outlined, size: 56, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No se encontraron pólizas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
