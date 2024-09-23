import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Verifica si el producto está presente y no es vacío.
    if (product.isEmpty || !product.containsKey('title')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
        ),
        body: const Center(
          child: Text('No product details available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product['title'] ?? 'No Title'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muestra una imagen de error si no se puede cargar la imagen
            Image.network(
              product['image'] ?? '',
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 100);
              },
            ),
            const SizedBox(height: 20),
            Text(
              product['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${product['price'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(product['description'] ?? 'No Description'),
          ],
        ),
      ),
    );
  }
}
