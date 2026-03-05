import 'package:flutter/material.dart';
import 'package:mr_app/widgets/new_list_product.dart';

void main() => runApp(const Product());

class Product extends StatelessWidget {
  const Product({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: NewsList(),
    );
  }
}
