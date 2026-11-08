import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../utils/colors.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final Map<Product, int> _cart = {};

  final List<String> _categories = [
    'All',
    'Pizza',
    'Pasta',
    'Main Dishes',
    'Appetizers',
    'Cold Drinks',
  ];

  void _addToCart(Product product) {
    setState(() {
      Product? existing;
      for (var p in _cart.keys) {
        if (p.id == product.id) {
          existing = p;
          break;
        }
      }
      if (existing != null) {
        _cart[existing] = (_cart[existing] ?? 0) + 1;
      } else {
        _cart[product] = 1;
      }
    });
  }

  int get _cartCount {
    int total = 0;
    _cart.forEach((_, qty) => total += qty);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yeyi's Pizzeria & Café", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Tanay, Rizal • Open 6:00 AM - 2:00 AM", style: TextStyle(fontSize: 11, color: AppColors.latte)),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cartItems: _cart,
                        onClearCart: () => setState(() => _cart.clear()),
                      ),
                    ),
                  );
                },
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.caramel, shape: BoxShape.circle),
                    child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.caramel,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.espresso,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Real-time Firestore Product Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.caramel));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No items available in Yeyi's menu yet.", style: TextStyle(color: AppColors.textMuted)),
                  );
                }

                final products = docs.map((doc) => Product.fromFirestore(doc)).where((p) {
                  if (_selectedCategory == 'All') return true;
                  return p.category.toLowerCase() == _selectedCategory.toLowerCase();
                }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Text("No items under '$_selectedCategory'", style: const TextStyle(color: AppColors.textMuted)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return ProductCard(
                      product: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(
                              product: item,
                              onAddToCart: _addToCart,
                            ),
                          ),
                        );
                      },
                      onAddToCart: () {
                        _addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.productName} added!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}