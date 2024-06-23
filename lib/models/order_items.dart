import 'package:final_project_level1/models/products.dart';

class OrderItem {
  int? orderId;
  int? productId;
  int? productCount;
  Product? product;

  OrderItem({
    this.orderId,
    this.productId,
    this.productCount,
    this.product,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    productId = json['productId'];
    productCount = json['productCount'];
    product = Product.fromJson(json);
  }
}