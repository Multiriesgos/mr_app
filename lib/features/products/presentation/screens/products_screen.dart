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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canPop)
            Semantics(
              label: 'Volver',
              button: true,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.arrow_back_sharp, size: 24),
                ),
              ),
            )
          else
            const SizedBox(width: 32),
          Text(
            'Productos contratados',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 32),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: products.length,
        itemBuilder: (context, i) => _ProductTile(product: products[i]),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final dateStr = product.fechaRenovacion == null
        ? ''
        : DateFormat('yyyy-MM-dd').format(product.fechaRenovacion!);

    return Semantics(
      label: '${product.ramo}, ${product.tipoSeguro}'
          '${product.placa.isNotEmpty ? ", placa ${product.placa}" : ""}'
          '${dateStr.isNotEmpty ? ", renovación $dateStr" : ""}',
      button: true,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.only(right: 2),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1, color: Colors.white24),
            ),
          ),
          child: const Icon(
            Icons.my_library_books_outlined,
            color: AppColors.accent,
            size: 40,
          ),
        ),
        title: Text(
          product.ramo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  product.placa.isNotEmpty
                      ? '${product.tipoSeguro}\n${product.placa}'
                      : product.tipoSeguro,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                dateStr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: product.placa.isNotEmpty,
        trailing: Icon(
          Icons.arrow_forward_ios_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        onTap: () =>
            context.push('/home/products/${product.idRen}', extra: product),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron productos.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
