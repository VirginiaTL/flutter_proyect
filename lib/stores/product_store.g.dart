// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductStore on _ProductStore, Store {
  late final _$productsAtom =
      Atom(name: '_ProductStore.products', context: context);

  @override
  List<dynamic> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(List<dynamic> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$selectedQuantitiesAtom =
      Atom(name: '_ProductStore.selectedQuantities', context: context);

  @override
  List<int> get selectedQuantities {
    _$selectedQuantitiesAtom.reportRead();
    return super.selectedQuantities;
  }

  @override
  set selectedQuantities(List<int> value) {
    _$selectedQuantitiesAtom.reportWrite(value, super.selectedQuantities, () {
      super.selectedQuantities = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProductStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isFetchingMoreAtom =
      Atom(name: '_ProductStore.isFetchingMore', context: context);

  @override
  bool get isFetchingMore {
    _$isFetchingMoreAtom.reportRead();
    return super.isFetchingMore;
  }

  @override
  set isFetchingMore(bool value) {
    _$isFetchingMoreAtom.reportWrite(value, super.isFetchingMore, () {
      super.isFetchingMore = value;
    });
  }

  late final _$fetchProductsAsyncAction =
      AsyncAction('_ProductStore.fetchProducts', context: context);

  @override
  Future<void> fetchProducts() {
    return _$fetchProductsAsyncAction.run(() => super.fetchProducts());
  }

  late final _$addToCartAsyncAction =
      AsyncAction('_ProductStore.addToCart', context: context);

  @override
  Future<void> addToCart(int productId, int quantity) {
    return _$addToCartAsyncAction
        .run(() => super.addToCart(productId, quantity));
  }

  late final _$_ProductStoreActionController =
      ActionController(name: '_ProductStore', context: context);

  @override
  void updateQuantity(int index, int value) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.updateQuantity');
    try {
      return super.updateQuantity(index, value);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onScroll() {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore._onScroll');
    try {
      return super._onScroll();
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _fetchMoreProducts() {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore._fetchMoreProducts');
    try {
      return super._fetchMoreProducts();
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
products: ${products},
selectedQuantities: ${selectedQuantities},
isLoading: ${isLoading},
isFetchingMore: ${isFetchingMore}
    ''';
  }
}
