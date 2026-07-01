import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_motion.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/app_empty_state.dart';
import 'package:mr_app/core/widgets/app_nav_bar.dart';
import 'package:mr_app/core/widgets/app_status_badge.dart';
import 'package:mr_app/core/widgets/carbon_inline_notification.dart';
import 'package:mr_app/core/widgets/carbon_tag.dart';
import 'package:mr_app/core/widgets/policy_utils.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;
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
      result = result.where(
        (p) =>
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
    final state    = ref.watch(productsProvider);
    final notifier = ref.read(productsProvider.notifier);
    final count    = state.value?.length;
    final title    = count != null && count > 0 ? 'Mis pólizas ($count)' : 'Mis pólizas';
    final fromCache = state.hasValue && notifier.fromCache;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sidebarBg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppNavBar(
          leading: context.canPop() ? AppNavBarLeading.back : AppNavBarLeading.none,
          title: title,
        ),
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
              _LastUpdatedBar(lastUpdated: notifier.lastUpdated),
              _SearchAndFilter(
                controller: _searchController,
                query: _query,
                filter: _filter,
                products: state.value ?? const [],
                onQueryChanged: (q) => setState(() => _query = q),
                onFilterChanged: (f) => setState(() => _filter = f),
              ),
              if (fromCache)
                const CarbonInlineNotification(
                  kind: CarbonNotificationKind.warning,
                  title: 'Datos sin conexión',
                  subtitle: 'No se pudo actualizar. Deslizá hacia abajo para reintentar.',
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(productsProvider.notifier).reload();
                    if (!mounted) return;
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
                  child: state.when(
                    skipLoadingOnReload: true,
                    loading: () => const SkeletonProductList(),
                    error: (e, _) => AppEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'No se pudo cargar',
                      message: e is AppException
                          ? e.message
                          : 'Sin conexión. Revisá tu internet e intentá de nuevo.',
                      action: () => ref.read(productsProvider.notifier).reload(),
                      actionLabel: 'Reintentar',
                      iconColor: AppColors.error,
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return AppEmptyState(
                          icon: Icons.policy_outlined,
                          title: 'Sin pólizas activas',
                          message: 'No encontramos pólizas vigentes\nasociadas a tu documento.',
                          action: () => launchUrl(
                            Uri.parse(ExternalLinks.cotizador),
                            mode: LaunchMode.externalApplication,
                          ),
                          actionLabel: 'Cotizar en línea',
                        );
                      }
                      final filtered = _applyFilter(products);
                      if (filtered.isEmpty) return const AppEmptySearchState();
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
    this.products = const [],
  });

  final TextEditingController       controller;
  final String                      query;
  final _PolicyFilter               filter;
  final ValueChanged<String>        onQueryChanged;
  final ValueChanged<_PolicyFilter> onFilterChanged;
  final List<Product>               products;

  List<Product> _textFiltered() {
    if (query.isEmpty || products.isEmpty) return products;
    final q = query.toLowerCase();
    return products.where((p) =>
      p.ramo.toLowerCase().contains(q) ||
      p.tipoSeguro.toLowerCase().contains(q) ||
      p.aseguradora.toLowerCase().contains(q) ||
      p.placa.toLowerCase().contains(q) ||
      (p.adjunto?.toLowerCase().contains(q) ?? false),
    ).toList();
  }

  String _label(String base, _PolicyFilter value) {
    if (products.isEmpty) return base;
    final now = DateTime.now();
    final tf  = _textFiltered();
    final n   = switch (value) {
      _PolicyFilter.all     => tf.length,
      _PolicyFilter.vigente => tf.where((p) {
        if (p.fechaRenovacion == null) return true;
        return p.fechaRenovacion!.difference(now).inDays > 30;
      }).length,
      _PolicyFilter.proxima => tf.where((p) {
        if (p.fechaRenovacion == null) return false;
        final d = p.fechaRenovacion!.difference(now).inDays;
        return d >= 0 && d <= 30;
      }).length,
      _PolicyFilter.vencida => tf.where((p) {
        if (p.fechaRenovacion == null) return false;
        return p.fechaRenovacion!.isBefore(now);
      }).length,
    };
    return '$base ($n)';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs,
          ),
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
                      onPressed: () { controller.clear(); onQueryChanged(''); },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              border: OutlineInputBorder(borderRadius: AppRadius.smBR),
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
              _FilterChip(label: _label('Todas',      _PolicyFilter.all),     value: _PolicyFilter.all,     filter: filter, onTap: onFilterChanged),
              _FilterChip(label: _label('Vigentes',   _PolicyFilter.vigente), value: _PolicyFilter.vigente, filter: filter, onTap: onFilterChanged),
              _FilterChip(label: _label('Por vencer', _PolicyFilter.proxima), value: _PolicyFilter.proxima, filter: filter, onTap: onFilterChanged),
              _FilterChip(label: _label('Vencidas',   _PolicyFilter.vencida), value: _PolicyFilter.vencida, filter: filter, onTap: onFilterChanged),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.filter,
    required this.onTap,
  });

  final String                      label;
  final _PolicyFilter               value;
  final _PolicyFilter               filter;
  final ValueChanged<_PolicyFilter> onTap;

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final isSelected = value == filter;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label:         Text(label),
        selected:      isSelected,
        onSelected:    (_) => onTap(value),
        selectedColor: cs.primary.withValues(alpha: 0.12),
        checkmarkColor: cs.primary,
        labelStyle: TextStyle(
          fontSize:    12,
          fontWeight:  isSelected ? FontWeight.w600 : FontWeight.w400,
          color:       isSelected ? cs.primary : cs.onSurfaceVariant,
        ),
        side: BorderSide(color: isSelected ? cs.primary : cs.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBR),
      ),
    );
  }
}

// ─── Barra de última actualización ───────────────────────────────────────────

class _LastUpdatedBar extends StatefulWidget {
  const _LastUpdatedBar({required this.lastUpdated});
  final DateTime? lastUpdated;

  @override
  State<_LastUpdatedBar> createState() => _LastUpdatedBarState();
}

class _LastUpdatedBarState extends State<_LastUpdatedBar> {
  late final StreamSubscription<void> _timer =
      Stream<void>.periodic(const Duration(seconds: 30))
          .listen((_) { if (mounted) setState(() {}); });

  @override
  void dispose() {
    unawaited(_timer.cancel());
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

// ─── Lista ────────────────────────────────────────────────────────────────────

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
        itemBuilder: (context, i) => _AnimatedPolicyCard(product: sorted[i], index: i),
      ),
    );
  }
}

class _AnimatedPolicyCard extends StatefulWidget {
  const _AnimatedPolicyCard({required this.product, required this.index});
  final Product product;
  final int     index;

  @override
  State<_AnimatedPolicyCard> createState() => _AnimatedPolicyCardState();
}

class _AnimatedPolicyCardState extends State<_AnimatedPolicyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.slow01,
  );

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.delayed(
        Duration(milliseconds: widget.index * AppMotion.fast01.inMilliseconds),
        () { if (mounted) unawaited(_ctrl.forward()); },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return _PolicyCard(product: widget.product);
    }
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _ctrl, curve: AppMotion.entrance),
      builder: (context, child) => Opacity(
        opacity: _ctrl.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _ctrl.value)),
          child: child,
        ),
      ),
      child: _PolicyCard(product: widget.product),
    );
  }
}

// ─── Carbon Tile mejorado ─────────────────────────────────────────────────────

enum _PolicyAction { detail, copy, share }

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final rColor   = PolicyUtils.colorForRamo(product.ramo);
    final rIcon    = PolicyUtils.iconForRamo(product.ramo);
    final dateStr  = product.fechaRenovacion != null
        ? DateFormat('dd/MM/yyyy').format(product.fechaRenovacion!)
        : null;
    final days = product.fechaRenovacion?.difference(DateTime.now()).inDays;

    return Semantics(
      label: '${product.ramo}, ${product.tipoSeguro}'
          '${product.placa.isNotEmpty ? ", placa ${product.placa}" : ""}'
          '${dateStr != null ? ", renovación $dateStr" : ""}',
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color:        cs.surface,
          borderRadius: AppRadius.mdBR,
          border:       Border.all(color: cs.outlineVariant),
          boxShadow:    AppColors.shadowSm,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.mdBR,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(
                '/home/products/${product.idRen}',
                extra: product,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Franja izquierda de color semántico
                    Container(width: 4, color: rColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm, AppSpacing.sm, 0, AppSpacing.sm,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'policy-icon-${product.idRen}',
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:        rColor.withValues(alpha: 0.10),
                                  borderRadius: AppRadius.smBR,
                                ),
                                child: Icon(rIcon, color: rColor, size: 20),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      if (product.fechaRenovacion != null) ...[
                                        const SizedBox(width: AppSpacing.xs),
                                        AppStatusBadge(date: product.fechaRenovacion),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    product.tipoSeguro,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  if (product.placa.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      product.placa,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:      cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                  if (dateStr != null) ...[
                                    const SizedBox(height: AppSpacing.xs),
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
                                                color:    cs.onSurfaceVariant,
                                                fontSize: 11,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (days != null && days <= 30) ...[
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
                                          await launchUrl(
                                            uri,
                                            mode: LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _OverflowMenu(product: product, ramoColor: rColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Overflow menu ────────────────────────────────────────────────────────────

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.product, required this.ramoColor});
  final Product product;
  final Color   ramoColor;

  Future<void> _onSelected(BuildContext context, _PolicyAction action) async {
    switch (action) {
      case _PolicyAction.detail:
        unawaited(context.push('/home/products/${product.idRen}', extra: product));
      case _PolicyAction.copy:
        await Clipboard.setData(ClipboardData(text: '${product.idRen}'));
        await HapticFeedback.lightImpact();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID de póliza copiado'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      case _PolicyAction.share:
        final dateStr = product.fechaRenovacion != null
            ? DateFormat('dd/MM/yyyy').format(product.fechaRenovacion!)
            : 'Sin fecha';
        final text = '📋 Póliza Multiriesgos\n'
            'Ramo: ${product.ramo}\n'
            'Tipo: ${product.tipoSeguro}\n'
            'Aseguradora: ${product.aseguradora}\n'
            '${product.placa.isNotEmpty ? "Placa: ${product.placa}\n" : ""}'
            'Renovación: $dateStr';
        await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<_PolicyAction>(
      onSelected: (action) => _onSelected(context, action),
      icon: Icon(Icons.more_vert, size: 20, color: cs.onSurfaceVariant),
      padding: EdgeInsets.zero,
      tooltip: 'Más acciones',
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smBR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      elevation: 2,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _PolicyAction.detail,
          child: Row(
            children: [
              Icon(Icons.open_in_new_outlined, size: 16),
              SizedBox(width: 12),
              Text('Ver detalle'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _PolicyAction.copy,
          child: Row(
            children: [
              Icon(Icons.content_copy_outlined, size: 16),
              SizedBox(width: 12),
              Text('Copiar ID de póliza'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _PolicyAction.share,
          child: Row(
            children: [
              Icon(Icons.share_outlined, size: 16),
              SizedBox(width: 12),
              Text('Compartir'),
            ],
          ),
        ),
      ],
    );
  }
}
