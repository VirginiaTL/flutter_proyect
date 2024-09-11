import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

// Página de Productos
class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = []; // Lista para almacenar los productos
  List<int> selectedQuantities = []; // Lista de cantidades por producto
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Llamada para obtener productos desde la API
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        products = data; // Asignar productos obtenidos
        selectedQuantities = List.generate(
            products.length, (index) => 1); // Iniciar cantidades en 1
        isLoading = false; // Cambiar estado de carga
      });
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator()) // Mostrar un indicador de carga
        : ListView.builder(
            padding: EdgeInsets.all(16),
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
                          width: 50,
                          height: 50,
                        ), // Mostrar imagen del producto
                        title: Text(
                            product['title']), // Mostrar nombre del producto
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Selector de cantidad
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
                          // Botón de añadir al carrito
                          ElevatedButton(
                            onPressed: () {
                              // Lógica para añadir al carrito
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
}

// Página de Categorías (puedes mantenerla igual por ahora)
class CategoriesPage extends StatelessWidget {
  final List<String> categories = ['Electrónica', 'Ropa', 'Hogar', 'Deportes'];

  @override
  Widget build(BuildContext context) {
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
            child: Text(categories[index]),
          ),
        );
      },
    );
  }
}

// Página del Carrito
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
