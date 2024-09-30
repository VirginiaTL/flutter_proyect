import 'package:mobx/mobx.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

part 'product_store.g.dart';

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

  int currentPage = 0;
  final int productsPerPage = 10;
  final ScrollController scrollController = ScrollController();

  _ProductStore() {
    fetchProducts();
    scrollController.addListener(_onScroll);
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
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      _fetchMoreProducts();
    }
  }

  @action
  void _fetchMoreProducts() {
    if (!isFetchingMore && (currentPage + 1) * productsPerPage < products.length) {
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

    if (userId == null) {
      throw Exception("Usuario no autenticado");
    }

    final cartData = {
      "userId": userId,
      "date": DateTime.now().toIso8601String(),
      "products": [
        {"productId": productId, "quantity": quantity}
      ]
    };

    final response = await http.post(
      Uri.parse('https://fakestoreapi.com/carts'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(cartData),
    );

    if (response.statusCode == 200) {
      print("Producto añadido al carrito");
    } else {
      throw Exception('Error al añadir al carrito');
    }
  }
}
