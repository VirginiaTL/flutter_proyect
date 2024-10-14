import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

part 'product_store.g.dart';

// @Injectable
class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  @observable
  List products = [];

  @observable
  List<int> selectedQuantities = [];

  @observable
  bool isLoading = true;

  @observable
  bool isFetchingMore = false;

  @observable
  late Box cartBox;

  int currentPage = 0;
  final int productsPerPage = 10;
  final ScrollController scrollController = ScrollController();

  _ProductStore() {
    fetchProducts();
    scrollController.addListener(_onScroll);
    _initCartBox(); // Inicializa la caja del carrito
  }

  Future<void> _initCartBox() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString("userId");
    cartBox = await Hive.openBox('cartBox');
  }

  @action
  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      products = data;
      selectedQuantities = List.generate(products.length, (index) => 1);
      isLoading = false;
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  @action
  void updateQuantity(int index, int value) {
    selectedQuantities[index] = value;
  }

  @action
  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _fetchMoreProducts();
    }
  }

  @action
  void _fetchMoreProducts() {
    if (!isFetchingMore &&
        (currentPage + 1) * productsPerPage < products.length) {
      isFetchingMore = true;
      Future.delayed(const Duration(seconds: 2), () {
        currentPage++;
        isFetchingMore = false;
      });
    }
  }

  @action
  Future<void> addToCart(int productId, int quantity) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString("userId");
    final userCart = cartBox.toString();
    print(userCart);

    if (userId == null) {
      throw Exception("Usuario no autenticado");
    }

    final cartKey = 'cart_$userId';

    final existingCart = cartBox.get(cartKey);

    // Comprobar si el carrito ya tiene productos
    final newProduct = {"productId": productId, "quantity": quantity};
    existingCart['products'].add(newProduct);

    // Guardar el carrito actualizado
    await cartBox.put(cartKey, existingCart);

    try {
      if (existingCart['products'].isNotEmpty) {
        existingCart['products'].add(newProduct);
      } else {
        existingCart['products'] = [newProduct];
      }
    } catch (e) {
      print('Error al añadir al carrito: $e');
    }
  }
}
