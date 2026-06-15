import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/core/theme/app_colors.dart';
import 'package:mr_app/core/widgets/skeleton_product_list.dart';
import 'package:mr_app/features/products/domain/entities/product.dart';
import 'package:mr_app/features/products/presentation/providers/products_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.idRen, super.key, this.product});

  final int idRen;
  final Product? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(idRen));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.sidebarBg,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: state.when(
            loading: () => const SkeletonProductDetail(),
            error: (e, _) => Center(
              child: Text(
                e is AppException
                    ? e.message
                    : 'Error inesperado. Por favor reintente.',
              ),
            ),
            data: (data) {
              final (detail, contact) = data;
              return _DetailBody(product: detail, contact: contact);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconColor,
  });

  final String? label;
  final Color bg;
  final Color border;
  final Color iconBg;
  final Color iconColor;
}

// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.product, this.contact});

  final Product product;
  final ContactInfo? contact;

  Future<void> _call(BuildContext context) async {
    final uri = Uri.parse('tel:+503${contact!.phone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsApp(BuildContext context) async {
    final number = '+503${contact!.whatsapp}';
    final uri = Platform.isIOS
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
    final cs = Theme.of(context).colorScheme;
    final dateStr = product.fechaRenovacion != null
        ? DateFormat('dd/MM/yyyy').format(product.fechaRenovacion!)
        : null;
    final status = _computeStatus(product.fechaRenovacion);

    final hasFinancial = product.suma != null ||
        product.primaNeta != null ||
        product.primaTotal != null ||
        (product.formaPago != null && product.formaPago!.isNotEmpty) ||
        (product.periodoPago != null && product.periodoPago!.isNotEmpty);
    final hasCoverage = product.descripcionSeguro != null &&
        product.descripcionSeguro!.isNotEmpty;
    final hasEjecutivo =
        product.ejecutivo != null && product.ejecutivo!.isNotEmpty;
    final hasContact =
        contact != null && (contact!.hasPhone || contact!.hasWhatsApp);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          // ── Barra de navegación ────────────────────────────────────────
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: AppColors.sidebarBg,
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Semantics(
                  label: 'Volver a Pólizas',
                  button: true,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_sharp, color: Colors.white, size: 24),
                    tooltip: 'Volver',
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Detalle de póliza',
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
          ),

          // ── Contenido ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero de estado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: status.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: status.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: status.iconBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconForRamo(product.ramo),
                            color: status.iconColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
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
                              const SizedBox(height: 2),
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
                        if (status.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: status.iconBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.label!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: status.iconColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Información general ──────────────────────────────
                  const SizedBox(height: 20),
                  const _SectionLabel('Información general'),
                  const SizedBox(height: 8),
                  _InfoCard(rows: [
                    _InfoRow('Tipo de seguro', product.tipoSeguro),
                    _InfoRow('Asegurado', product.asegurado),
                    if (product.placa.isNotEmpty)
                      _InfoRow('Placa / Identificador', product.placa),
                    if (dateStr != null)
                      _InfoRow('Fecha de renovación', dateStr),
                    _InfoRow(
                      'N.° de póliza',
                      product.adjunto?.isNotEmpty ?? false
                          ? product.adjunto!
                          : 'No disponible',
                    ),
                  ],),

                  // ── Cobertura ────────────────────────────────────────
                  if (hasCoverage) ...[
                    const SizedBox(height: 16),
                    const _SectionLabel('Cobertura'),
                    const SizedBox(height: 8),
                    _InfoCard(rows: [
                      _InfoRow('Descripción', product.descripcionSeguro!),
                    ],),
                  ],

                  // ── Financiero ───────────────────────────────────────
                  if (hasFinancial) ...[
                    const SizedBox(height: 16),
                    const _SectionLabel('Financiero'),
                    const SizedBox(height: 8),
                    _InfoCard(rows: [
                      if (product.suma != null)
                        _InfoRow('Suma asegurada', _fmtCurrency(product.suma!)),
                      if (product.primaNeta != null)
                        _InfoRow('Prima neta', _fmtCurrency(product.primaNeta!)),
                      if (product.primaTotal != null)
                        _InfoRow('Prima total', _fmtCurrency(product.primaTotal!)),
                      if (product.formaPago != null &&
                          product.formaPago!.isNotEmpty)
                        _InfoRow('Forma de pago', product.formaPago!),
                      if (product.periodoPago != null &&
                          product.periodoPago!.isNotEmpty)
                        _InfoRow('Período de pago', product.periodoPago!),
                    ],),
                  ],

                  // ── Asesor ───────────────────────────────────────────
                  if (hasEjecutivo) ...[
                    const SizedBox(height: 16),
                    const _SectionLabel('Asesor'),
                    const SizedBox(height: 8),
                    _InfoCard(rows: [
                      _InfoRow('Ejecutivo', product.ejecutivo!),
                    ],),
                  ],

                  // ── Contacto de cabina ───────────────────────────────
                  if (hasContact) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel('Contacto de cabina'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (contact!.hasPhone)
                          Expanded(
                            child: _ContactButton(
                              label: 'Llamar',
                              semanticsLabel:
                                  'Llamar a cabina de ${product.aseguradora}',
                              color: AppColors.info,
                              iconData: Icons.phone_outlined,
                              onTap: () => _call(context),
                            ),
                          ),
                        if (contact!.hasPhone && contact!.hasWhatsApp)
                          const SizedBox(width: 12),
                        if (contact!.hasWhatsApp)
                          Expanded(
                            child: _ContactButton(
                              label: 'WhatsApp',
                              semanticsLabel:
                                  'WhatsApp a ${product.aseguradora}',
                              color: AppColors.success,
                              iconData: Icons.chat_bubble_outline,
                              onTap: () => _whatsApp(context),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtCurrency(double v) =>
      NumberFormat.currency(locale: 'en_US', symbol: r'$ ', decimalDigits: 2)
          .format(v);

  IconData _iconForRamo(String ramo) {
    final r = ramo.toLowerCase();
    if (r.contains('auto') || r.contains('veh')) return Icons.directions_car_outlined;
    if (r.contains('vida')) return Icons.favorite_border;
    if (r.contains('salud') || r.contains('medic')) return Icons.medical_services_outlined;
    if (r.contains('incendio') || r.contains('hogar')) return Icons.home_outlined;
    return Icons.description_outlined;
  }

  _StatusInfo _computeStatus(DateTime? date) {
    if (date == null) {
      return const _StatusInfo(
        label: null,
        bg: AppColors.background,
        border: AppColors.borderLight,
        iconBg: Color(0x1A1530B8),
        iconColor: AppColors.primary,
      );
    }
    final days = date.difference(DateTime.now()).inDays;
    if (days < 0) {
      return const _StatusInfo(
        label: 'Vencida',
        bg: AppColors.errorBg,
        border: Color(0x33DC2626),
        iconBg: Color(0x1FDC2626),
        iconColor: AppColors.errorDark,
      );
    }
    if (days <= 30) {
      return _StatusInfo(
        label: 'Vence en ${days}d',
        bg: AppColors.warningBg,
        border: const Color(0x40CA8A04),
        iconBg: const Color(0x1FCA8A04),
        iconColor: AppColors.warningDark,
      );
    }
    return const _StatusInfo(
      label: 'Vigente',
      bg: AppColors.successBg,
      border: Color(0x3316A34A),
      iconBg: Color(0x1F16A34A),
      iconColor: AppColors.successDark,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, indent: 16, endIndent: 16, color: cs.outlineVariant),
          ],
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'No disponible' : value,
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

  final String label;
  final String semanticsLabel;
  final Color color;
  final IconData iconData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(iconData, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
