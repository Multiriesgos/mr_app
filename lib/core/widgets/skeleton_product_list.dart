import 'package:flutter/material.dart';
import 'package:mr_app/core/widgets/shimmer_box.dart';

/// Skeleton placeholder para la lista de productos mientras carga.
class SkeletonProductList extends StatelessWidget {
  const SkeletonProductList({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: itemCount,
        itemBuilder: (_, __) => const _SkeletonTile(),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          const ShimmerBox(width: 44, height: 44, borderRadius: 8),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  height: 14,
                ),
                const SizedBox(height: 7),
                ShimmerBox(
                  width: MediaQuery.sizeOf(context).width * 0.35,
                  height: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const ShimmerBox(width: 20, height: 20),
        ],
      ),
    );
  }
}

/// Skeleton placeholder para el detalle de producto.
class SkeletonProductDetail extends StatelessWidget {
  const SkeletonProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: ShimmerBox(width: 130, height: 130, borderRadius: 65),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 80, height: 11),
                    SizedBox(height: 6),
                    ShimmerBox(width: double.infinity, height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
