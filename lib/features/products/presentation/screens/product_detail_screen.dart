import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/core/config/external_links.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/platform/app_platform.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/theme/app_radius.dart';
import 'package:mr_app/core/theme/app_spacing.dart';
import 'package:mr_app/core/widgets/app_nav_bar.dart';
import 'package:mr_app/core/widgets/app_status_badge.dart';
import 'package:mr_app/core/widgets/carbon_inline_notification.dart';
import 'package:mr_app/core/widgets/policy_utils.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.idRen, super.key, this.product});

  final int      idRen;
  final Product? product;

  void _share(Product p) {
    final dateStr = p.fechaRenovacion != null
        ? DateFormat('dd/MM/yyyy').format(p.fechaRenovacion!)
        : 'N/D';
    final hasVehiculo = (p.marca?.isNotEmpty ?? false) ||
        (p.modelo?.isNotEmpty ?? false) ||
        (p.anioVehiculo?.isNotEmpty ?? false);
    final lines = [
      'Póliza — ${p.ramo}',
      'Tipo: ${p.tipoSeguro}',
      'Asegurado: ${p.asegurado}',
      'Renovación: $dateStr',
      'Aseguradora: ${p.aseguradora}',
      if (hasVehiculo) ...[
        if (p.marca?.isNotEmpty ?? false) 'Marca: ${p.marca}',
        if (p.modelo?.isNotEmpty ?? false) 'Modelo: ${p.modelo}',
        if (p.anioVehiculo?.isNotEmpty ?? false) 'Año: ${p.anioVehiculo}',
      ],
      if (p.suma != null) 'Suma: \$${p.suma!.toStringAsFixed(2)}',
      if (p.primaTotal != null) 'Prima total: \$${p.primaTotal!.toStringAsFixed(2)}',
      if (p.primaMes != null) 'Cuota mensual: \$${p.primaMes!.toStringAsFixed(2)}',
    ];
    unawaited(
      SharePlus.instance.share(
        ShareParams(
          text: lines.join('\n'),
          subject: 'Detalle de póliza — ${p.ramo}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(idRen));

    // Usamos el producto del cache (pasado via extra) para mostrar
    // el título y el botón compartir incluso durante la carga.
    final cachedProduct = product;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sidebarBg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppNavBar(
          title: 'Detalle de póliza',
          backLabel: 'Pólizas',
          actions: [
            if (cachedProduct != null)
              Semantics(
                label: 'Compartir póliza',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                  tooltip: 'Compartir',
                  onPressed: () => _share(cachedProduct),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: state.when(
            loading: () => const SkeletonProductDetail(),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color:  AppColors.errorBg,
                        shape:  BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_off_outlined, color: AppColors.error, size: 36),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      e is AppException ? e.message : 'Error inesperado. Por favor reintente.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.tonal(
                      onPressed: () => context.pop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            ),
            data: (data) {
              final (detail, contact) = data;
              return _DetailBody(
                product: detail,
                contact: contact,
                onShare: () => _share(detail),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.product, required this.onShare, this.contact});

  final Product      product;
  final ContactInfo? contact;
  final VoidCallback onShare;

  Future<void> _call(BuildContext context) async {
    final uri = Uri.parse('tel:+503${contact!.phone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsApp(BuildContext context) async {
    final number = '+503${contact!.whatsapp}';
    final uri = AppPlatform.isIOS
        ? Uri.parse('https://wa.me/$number?text=Hola')
        : Uri.parse('whatsapp://send?phone=$number&text=Hola');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp no está instalado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final status  = PolicyUtils.statusOf(product.fechaRenovacion);
    final rColor  = PolicyUtils.colorForRamo(product.ramo);
    final rIcon   = PolicyUtils.iconForRamo(product.ramo);
    final days    = product.fechaRenovacion != null
        ? product.fechaRenovacion!.difference(DateTime.now()).inDays
        : 0;
    final dateStr = product.fechaRenovacion != null
        ? DateFormat('dd/MM/yyyy').format(product.fechaRenovacion!)
        : null;

    final hasFinancial = product.suma != null ||
        product.primaTotal != null ||
        product.primaMes != null;
    final hasVehiculo = (product.marca?.isNotEmpty ?? false) ||
        (product.modelo?.isNotEmpty ?? false) ||
        (product.anioVehiculo?.isNotEmpty ?? false);
    final hasContact = contact != null && (contact!.hasPhone || contact!.hasWhatsApp);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingH, AppSpacing.pagePaddingH,
          AppSpacing.pagePaddingH, AppSpacing.sectionGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero de estado
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:        status.bgColor,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: status.color.withValues(alpha: 0.20)),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'policy-icon-${product.idRen}',
                    child: Container(
                      width:  48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:        rColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smBR,
                      ),
                      child: Icon(rIcon, color: rColor, size: 26),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.ramo,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.s01),
                        Text(
                          product.aseguradora,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  AppStatusBadge(date: product.fechaRenovacion),
                ],
              ),
            ),

            // CTA renovación
            if (product.fechaRenovacion != null && days <= 30)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.cardGap),
                child: CarbonInlineNotification(
                  kind: product.fechaRenovacion!.isBefore(DateTime.now())
                      ? CarbonNotificationKind.error
                      : CarbonNotificationKind.warning,
                  title: product.fechaRenovacion!.isBefore(DateTime.now())
                      ? 'Póliza vencida'
                      : 'Próxima a vencer',
                  subtitle: 'Cotiza tu renovación',
                  onAction: () async {
                    final uri = Uri.parse(ExternalLinks.cotizador);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),

            // Información general
            const SizedBox(height: AppSpacing.pagePaddingH),
            const _SectionLabel('Información general'),
            const SizedBox(height: AppSpacing.sm),
            _InfoCard(rows: [
              _InfoRow('Tipo de seguro', product.tipoSeguro),
              _InfoRow('Asegurado', product.asegurado),
              if (dateStr != null)
                _InfoRow('Fecha renovación', dateStr),
            ],),

            // Vehículo
            if (hasVehiculo) ...[
              const SizedBox(height: AppSpacing.md),
              const _SectionLabel('Vehículo'),
              const SizedBox(height: AppSpacing.sm),
              _InfoCard(rows: [
                if (product.marca?.isNotEmpty ?? false)
                  _InfoRow('Marca', product.marca!),
                if (product.modelo?.isNotEmpty ?? false)
                  _InfoRow('Modelo', product.modelo!),
                if (product.anioVehiculo?.isNotEmpty ?? false)
                  _InfoRow('Año vehículo', product.anioVehiculo!),
              ],),
            ],

            // Financiero
            if (hasFinancial) ...[
              const SizedBox(height: AppSpacing.md),
              const _SectionLabel('Financiero'),
              const SizedBox(height: AppSpacing.sm),
              _InfoCard(rows: [
                if (product.suma != null)
                  _AnimatedCurrencyRow('Suma', product.suma!),
                if (product.primaTotal != null)
                  _AnimatedCurrencyRow('Prima total', product.primaTotal!),
                if (product.primaMes != null)
                  _AnimatedCurrencyRow('Cuota mensual', product.primaMes!),
              ],),
            ],

            // Contacto de cabina
            if (hasContact) ...[
              const SizedBox(height: AppSpacing.pagePaddingH),
              const _SectionLabel('Contacto de cabina'),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (contact!.hasPhone)
                    Expanded(
                      child: _ContactButton(
                        label:          'Llamar',
                        semanticsLabel: 'Llamar a cabina de ${product.aseguradora}',
                        color:          AppColors.info,
                        iconData:       Icons.phone_outlined,
                        onTap:          () => _call(context),
                      ),
                    ),
                  if (contact!.hasPhone && contact!.hasWhatsApp)
                    const SizedBox(width: AppSpacing.s04),
                  if (contact!.hasWhatsApp)
                    Expanded(
                      child: _ContactButton(
                        label:          'WhatsApp',
                        semanticsLabel: 'WhatsApp a ${product.aseguradora}',
                        color:          AppColors.success,
                        iconData:       Icons.chat_bubble_outline,
                        onTap:          () => _whatsApp(context),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Componentes de UI ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color:         Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: AppRadius.mdBR,
        border:       Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: cs.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedCurrencyRow extends StatelessWidget {
  const _AnimatedCurrencyRow(this.label, this.amount);
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical:   AppSpacing.s04,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: amount),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, value, __) => Text(
                NumberFormat.currency(
                  locale:        'en_US',
                  symbol:        r'$ ',
                  decimalDigits: 2,
                ).format(value),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs          = Theme.of(context).colorScheme;
    final displayValue = value.isEmpty ? 'No disponible' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical:   AppSpacing.s04,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.semanticsLabel,
    required this.color,
    required this.iconData,
    required this.onTap,
  });

  final String     label;
  final String     semanticsLabel;
  final Color      color;
  final IconData   iconData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:  semanticsLabel,
      button: true,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon:  Icon(iconData, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side:            BorderSide(color: color),
          minimumSize:     const Size(double.infinity, 48),
          shape:           RoundedRectangleBorder(borderRadius: AppRadius.smBR),
        ),
      ),
    );
  }
}
