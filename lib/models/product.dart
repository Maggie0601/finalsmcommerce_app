import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String productName;
  final double price;
  final String description;
  final String imageUrl;
  final int stock;
  final String category;
  final String subCategory;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.category,
    this.subCategory = '',
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      productName: data['productName'] ?? 'Unnamed Item',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? 'https://picsum.photos/300/200?random=1',
      stock: (data['stock'] is num) ? (data['stock'] as num).toInt() : 0,
      category: data['category'] ?? 'All',
      subCategory: data['subCategory'] ?? '',
    );
  }
}