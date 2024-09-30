import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class CartItem extends HiveObject {
  @HiveField(0)
  final int productId;

  @HiveField(1)
  final int quantity;

  CartItem({required this.productId, required this.quantity});
}
