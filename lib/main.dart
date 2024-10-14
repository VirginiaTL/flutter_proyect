// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/pages/login_page.dart';
import 'dart:convert';

import 'package:proyecto_flutter/screens/product_detail_page.dart';
import 'package:proyecto_flutter/stores/product_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await Hive.initFlutter();

  // Abre la caja donde almacenarás el carrito
  await Hive.openBox('cartBox');
  runApp(
    Provider(
      create: (_) => ProductStore()..fetchProducts(),
      child: MyApp(),
    ),
  );
}

Future<Map<String, dynamic>> fetchProductDetails(String productId) async {
  final response =
      await http.get(Uri.parse('https://fakestoreapi.com/products/$productId'));

  if (response.statusCode == 200) {
    // Decodifica la respuesta y retorna los detalles del producto.
    return json.decode(response.body);
  } else {
    // Maneja el error en caso de que no se pueda obtener el producto.
    throw Exception('Error al cargar los detalles del producto');
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(),
      ),
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
          final product = state.extra as Map<String, dynamic>? ?? {};
          return ProductDetailPage(product: product);
        },
      ),
      GoRoute(
        path: '/product-details/:id',
        builder: (context, state) {
          final productId =
              state.params['id']; // Obtén el productId desde la URL.

          return FutureBuilder<Map<String, dynamic>>(
            future: fetchProductDetails(
                productId!), // Llama a la función que obtiene los detalles del producto.
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Muestra un indicador de carga mientras se obtienen los datos.
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text(
                        'Error al cargar los detalles del producto.')); // Maneja el error si la carga falla.
              } else if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return const Center(
                    child: Text(
                        'No se encontraron detalles del producto.')); // Si no hay datos.
              } else {
                final product =
                    snapshot.data!; // Detalles del producto obtenidos.
                return ProductDetailPage(
                    product:
                        product); // Muestra la página de detalles del producto.
              }
            },
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E-Commerce Layout',
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProductsPage(),
    const CategoriesPage(),
    const CartPage(),
  ];

  void _logout(BuildContext context) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove("userId"); // Eliminar el ID del usuario

    // También puedes eliminar el carrito del Hive si lo deseas
    await Hive.box('cartBox').clear();

    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'List of products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  Future<void> addToCart(int productId, int quantity) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString("userId");

    if (userId == null) {
      throw Exception("Usuario no autenticado");
    }

    // Obtener el carrito existente de Hive
    final boxCart = await Hive.openBox('cartBox');
    final cartKey = 'cart_$userId';
    final existingCart = boxCart.get(cartKey, defaultValue: []);

    // Buscar si el producto ya está en el carrito para actualizar la cantidad
    var existingProductIndex =
        existingCart.indexWhere((product) => product['productId'] == productId);

    if (existingProductIndex != -1) {
      // Si el producto ya existe en el carrito, actualiza la cantidad
      existingCart[existingProductIndex]['quantity'] += quantity;
    } else {
      // Si el producto no está en el carrito, añade uno nuevo
      final newProduct = {
        "productId": productId,
        "quantity": quantity,
      };
      existingCart.add(newProduct);
    }

    // Guardar el carrito actualizado de nuevo en Hive
    await boxCart.put(cartKey, existingCart);
    await boxCart.close();
  }

  @override
  Widget build(BuildContext context) {
    final productStore = Provider.of<ProductStore>(context);

    return Scaffold(
      body: Observer(
        builder: (_) {
          if (productStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productStore.products.length,
            itemBuilder: (context, index) {
              final product = productStore.products[index];
              return GestureDetector(
                onTap: () {
                  final productId = product['id'].toString();
                  GoRouter.of(context).go('/product-details/$productId');
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.network(
                            product['image'],
                            width: 100,
                            height: 100,
                          ),
                          title: Text(product['title']),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Quantity:'),
                                const SizedBox(width: 10),
                                DropdownButton<int>(
                                  value: productStore.selectedQuantities[index],
                                  items: List.generate(10, (i) => i + 1)
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e,
                                            child: Text('$e'),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    productStore.updateQuantity(index, value!);
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final productId = product['id'];
                                final quantity =
                                    productStore.selectedQuantities[index];

                                try {
                                  await addToCart(productId, quantity);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Producto añadido al carrito con cantidad: $quantity y productId: $productId'),
                                    ),
                                  );
                                  // Opcional: Refrescar la lista de productos en la página de carrito si es necesario.
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Error al añadir al carrito')),
                                  );
                                }
                              },
                              child: const Text('Add to cart'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> categories = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = List<String>.from(data);
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception('Error al cargar categorías');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _onCategoryTap(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return const Center(child: Text('Error al cargar categorías'));
    }

    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onCategoryTap(categories[index]),
          child: Card(
            child: Center(
              child: Text(capitalize(categories[index])),
            ),
          ),
        );
      },
    );
  }
}

class CategoryProductsPage extends StatefulWidget {
  final String category;

  const CategoryProductsPage({super.key, required this.category});

  @override
  _CategoryProductsPageState createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
    final response = await http.get(Uri.parse(
        'https://fakestoreapi.com/products/category/${widget.category}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        products = data;
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar productos de la categoría');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.toUpperCase()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.network(
                            product['image'],
                            width: 100,
                            height: 100,
                          ),
                          title: Text(product['title']),
                        ),
                        Text('Price: \$${product['price']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<dynamic>> futureCartProducts;

  @override
  void initState() {
    super.initState();
    futureCartProducts = fetchCartProducts();
  }

  Future<List<dynamic>> fetchCartProducts() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString("userId");

    if (userId == null) {
      return [];
    }

    final boxCart = await Hive.openBox('cartBox');
    final cartKey = 'cart_$userId';
    final cartProducts = boxCart.get(cartKey, defaultValue: []);

    List<dynamic> detailedProducts = [];

    // Para cada producto en el carrito, obtenemos sus detalles
    for (var product in cartProducts) {
      final productId = product['productId'];
      final productDetailsResponse = await http
          .get(Uri.parse('https://fakestoreapi.com/products/$productId'));

      if (productDetailsResponse.statusCode == 200) {
        final productDetails = json.decode(productDetailsResponse.body);
        productDetails['quantity'] = product['quantity'];
        detailedProducts.add(productDetails);
      } else {
        throw Exception('Error al obtener detalles del producto');
      }
    }

    await boxCart.close();
    return detailedProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureCartProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 24),
              ),
            );
          } else {
            // Muestra la lista de productos con detalles
            final cartProducts = snapshot.data!;
            return ListView.builder(
              itemCount: cartProducts.length,
              itemBuilder: (context, index) {
                final product = cartProducts[index];
                return ListTile(
                  leading:
                      Image.network(product['image']), // Imagen del producto
                  title: Text(product['title']), // Nombre del producto
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${product['price']}'),
                      Text(
                          'Quantity: ${product['quantity']}'), // Cantidad del carrito
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
