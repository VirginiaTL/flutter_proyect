import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce Layout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProductsPage(),
    CategoriesPage(),
    CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Commerce App'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Productos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categorías'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Carrito'),
        ],
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = [];
  List<int> selectedQuantities = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  int currentPage = 0;
  final int productsPerPage = 10; // Número de productos por "página"
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        products = data; // Asignar productos obtenidos
        selectedQuantities = List.generate(products.length, (index) => 1);
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreProducts();
    }
  }

  void _fetchMoreProducts() {
    if (!isFetchingMore &&
        (currentPage + 1) * productsPerPage < products.length) {
      setState(() {
        isFetchingMore = true;
      });

      // Simulación de carga adicional de datos
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          currentPage++;
          isFetchingMore = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            itemCount:
                (currentPage + 1) * productsPerPage + (isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return null;
              }
              if (index >= (currentPage + 1) * productsPerPage) {
                return Center(child: CircularProgressIndicator());
              }

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Cantidad:'),
                              SizedBox(width: 10),
                              DropdownButton<int>(
                                value: selectedQuantities[index],
                                items: List.generate(10, (i) => i + 1)
                                    .map((e) => DropdownMenuItem<int>(
                                          value: e,
                                          child: Text('$e'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedQuantities[index] = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              print(
                                  'Añadir ${product['title']} al carrito con cantidad ${selectedQuantities[index]}');
                            },
                            child: Text('Añadir al carrito'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class CategoriesPage extends StatefulWidget {
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
          categories = List<String>.from(
              data); // Convertir la respuesta a una lista de Strings
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(child: Text('Error al cargar categorías'));
    }

    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text(capitalize(categories[index])),
          ),
        );
      },
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tu carrito está vacío',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
