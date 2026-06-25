import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/carbon_tag.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

enum _PolicyFilter { all, vigente, proxima, vencida }

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _PolicyFilter _filter = _PolicyFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _applyFilter(List<Product> products) {
    var result = products;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((p) =>
        p.ramo.toLowerCase().contains(q) ||
        p.tipoSeguro.toLowerCase().contains(q) ||
        p.aseguradora.toLowerCase().contains(q) ||
        p.placa.toLowerCase().contains(q) ||
        (p.adjunto?.toLowerCase().contains(q) ?? false),
      ).toList();
    }
    final now = DateTime.now();
    return switch (_filter) {
      _PolicyFilter.all => result,
      _PolicyFilter.vigente => result.where((p) {
          if (p.fechaRenovacion == null) return true;
          return p.fechaRenovacion!.difference(now).inDays > 30;
        }).toList(),
      _PolicyFilter.proxima => result.where((p) {
          if (p.fechaRenovacion == null) return false;
          final d = p.fechaRenovacion!.difference(now).inDays;
          return d >= 0 && d <= 30;
        }).toList(),
      _PolicyFilter.vencida => result.where((p) {
          if (p.fechaRenovacion == null) return false;
          return p.fechaRenovacion!.isBefore(now);
        }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sidebarBg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final uri = Uri.parse(ExternalLinks.cotizador);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Cotizar'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                onBack: () => context.pop(),
                count: state.valueOrNull?.length,
              ),
              _LastUpdatedBar(
                lastUpdated: ref.watch(productsProvider.notifier).lastUpdated,
              ),
              _SearchAndFilter(
                controller: _searchController,
                query: _query,
                filter: _filter,
                onQueryChanged: (q) => setState(() => _query = q),
                onFilterChanged: (f) => setState(() => _filter = f),
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
                    data: (products) {
                      if (products.isEmpty) return const _EmptyView();
                      final filtered = _applyFilter(products);
                      if (filtered.isEmpty) return const _EmptySearchView();
                      return _ProductList(products: filtered);
                    },
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

// ─── Búsqueda y filtros ───────────────────────────────────────────────────────

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.controller,
    required this.query,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final String query;
  final _PolicyFilter filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_PolicyFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
          child: TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar por ramo, placa, aseguradora…',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.clear();
                        onQueryChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _FilterChipItem(label: 'Todas', value: _PolicyFilter.all, selected: filter, onTap: onFilterChanged),
              _FilterChipItem(label: 'Vigentes', value: _PolicyFilter.vigente, selected: filter, onTap: onFilterChanged),
              _FilterChipItem(label: 'Por vencer', value: _PolicyFilter.proxima, selected: filter, onTap: onFilterChanged),
              _FilterChipItem(label: 'Vencidas', value: _PolicyFilter.vencida, selected: filter, onTap: onFilterChanged),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final _PolicyFilter value;
  final _PolicyFilter selected;
  final ValueChanged<_PolicyFilter> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = value == selected;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(value),
        selectedColor: cs.primary.withValues(alpha: 0.12),
        checkmarkColor: cs.primary,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? cs.primary : cs.onSurfaceVariant,
        ),
        side: BorderSide(
          color: isSelected ? cs.primary : cs.outlineVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// ─── Empty search result ──────────────────────────────────────────────────────

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sin resultados',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'No hay pólizas que coincidan con tu búsqueda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.count});
  final VoidCallback onBack;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final title = count != null && count! > 0
        ? 'Mis pólizas ($count)'
        : 'Mis pólizas';
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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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

class _LastUpdatedBar extends StatefulWidget {
  const _LastUpdatedBar({required this.lastUpdated});
  final DateTime? lastUpdated;

  @override
  State<_LastUpdatedBar> createState() => _LastUpdatedBarState();
}

class _LastUpdatedBarState extends State<_LastUpdatedBar> {
  late final _timer = Stream<void>.periodic(const Duration(seconds: 30))
      .listen((_) { if (mounted) setState(() {}); });

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _label() {
    if (widget.lastUpdated == null) return '';
    final diff = DateTime.now().difference(widget.lastUpdated!);
    if (diff.inSeconds < 60) return 'Actualizado hace un momento';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'Actualizado hace $m min';
    }
    final h = diff.inHours;
    return 'Actualizado hace $h ${h == 1 ? "hora" : "horas"}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lastUpdated == null) return const SizedBox.shrink();
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s04),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sorted.length,
        itemBuilder: (context, i) =>
            _AnimatedPolicyCard(product: sorted[i], index: i),
      ),
    );
  }
}

class _AnimatedPolicyCard extends StatefulWidget {
  const _AnimatedPolicyCard({required this.product, required this.index});
  final Product product;
  final int index;

  @override
  State<_AnimatedPolicyCard> createState() => _AnimatedPolicyCardState();
}

class _AnimatedPolicyCardState extends State<_AnimatedPolicyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _ctrl.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - _ctrl.value)),
          child: child,
        ),
      ),
      child: _PolicyCard(product: widget.product),
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
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
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
              padding: const EdgeInsets.all(AppSpacing.md),
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
                  const SizedBox(width: AppSpacing.cardGap),
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
                              const SizedBox(width: AppSpacing.sm),
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
                              const SizedBox(width: AppSpacing.xs),
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
                          const SizedBox(height: AppSpacing.iconTileGap),
                          CarbonTag(
                            label: 'Renovar',
                            type: product.fechaRenovacion!.isBefore(DateTime.now())
                                ? CarbonTagType.error
                                : CarbonTagType.warning,
                            icon: Icons.autorenew_rounded,
                            onTap: () async {
                              final uri = Uri.parse(ExternalLinks.cotizador);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
    if (days < 0) return const CarbonTag(label: 'Vencida', type: CarbonTagType.error);
    if (days <= 30) return CarbonTag(label: 'Vence en ${days}d', type: CarbonTagType.warning);
    return const CarbonTag(label: 'Vigente', type: CarbonTagType.success);
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
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.pagePaddingH),
                  Text(
                    'Sin pólizas activas',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No encontramos pólizas vigentes\nasociadas a tu documento.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
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
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.pagePaddingH),
                  Text(
                    'No se pudo cargar',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
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
