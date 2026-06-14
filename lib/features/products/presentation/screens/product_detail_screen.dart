import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
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
    );
  }
}

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      label: 'Volver a Productos',
                      button: true,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.arrow_back_sharp, size: 28),
                        ),
                      ),
                    ),
                    Text(
                      'Detalle de póliza',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'ASEGURADORA', value: product.aseguradora),
              _InfoRow(label: 'RAMO', value: product.ramo),
              _InfoRow(label: 'TIPO SEGURO', value: product.tipoSeguro),
              _InfoRow(label: 'ASEGURADO', value: product.asegurado),
              _InfoRow(
                label: 'PÓLIZA',
                value: product.adjunto ?? 'no disponible',
              ),
              const SizedBox(height: 24),
              if (contact != null &&
                  (contact!.hasPhone || contact!.hasWhatsApp)) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'CONTACTO DE CABINA',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                  ),
                ),
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
                              'Contactar por WhatsApp a ${product.aseguradora}',
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Container(
            constraints: const BoxConstraints(minHeight: 40),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              value.isEmpty ? 'no disponible' : value,
              style: Theme.of(context).textTheme.bodyLarge,
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
        icon: Icon(iconData, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          minimumSize: const Size(double.infinity, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
