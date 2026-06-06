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
                      'Detalle de producto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Contacto Cabina',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                ),
              ),
              const Center(
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/7_fit.png'),
                    radius: 60,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'ASEGURADORA', value: product.aseguradora),
              _InfoRow(label: 'RAMO', value: product.ramo),
              _InfoRow(label: 'TIPO SEGURO', value: product.tipoSeguro),
              _InfoRow(label: 'ASEGURADO', value: product.asegurado),
              _InfoRow(
                label: 'PÓLIZA',
                value: product.adjunto ?? 'no disponible',
              ),
              const SizedBox(height: 16),
              if (contact != null &&
                  (contact!.hasPhone || contact!.hasWhatsApp))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (contact!.hasPhone)
                      _ContactButton(
                        label: 'Cabina',
                        semanticsLabel: 'Llamar a cabina de ${product.aseguradora}',
                        color: AppColors.info,
                        icon: const Icon(
                          Icons.phone_enabled_outlined,
                          size: 50,
                          color: AppColors.info,
                        ),
                        onTap: () => _call(context),
                      ),
                    if (contact!.hasWhatsApp)
                      _ContactButton(
                        label: 'WhatsApp',
                        semanticsLabel:
                            'Contactar por WhatsApp a ${product.aseguradora}',
                        color: AppColors.success,
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          size: 50,
                          color: AppColors.success,
                        ),
                        onTap: () => _whatsApp(context),
                      ),
                  ],
                ),
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
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final Color color;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ink(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: icon,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
