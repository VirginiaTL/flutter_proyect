import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final int quantity;

  CartItem({required this.productId, required this.quantity});
}
