import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../utils/colors.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'customer_orders_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _selectedBeverageSubCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final Map<Product, int> _cart = {};

  final List<dynamic> _categoryTabs = [
    {'title': 'All', 'icon': Icons.restaurant_menu},
    {'title': 'Sizzling Plates', 'icon': Icons.whatshot},
    {'title': 'Pizza', 'icon': Icons.local_pizza},
    {'title': 'Pasta', 'icon': Icons.dinner_dining},
    {'title': 'Main Dishes', 'icon': Icons.set_meal},
    {'title': 'Breakfast', 'icon': Icons.breakfast_dining},
    {'title': 'Appetizers', 'icon': Icons.tapas},
    {'title': 'Beverages', 'icon': Icons.local_cafe},
  ];

  final List<String> _beverageSubCategories = [
    'All',
    'Cold Drinks (Coffee Based)',
    'Cold Drinks (Non-Coffee Based)',
    'Hot Drinks (Coffee Based)',
    'Hot Drinks (Non-Coffee & Teas)',
    'Soda Based',
    'Juices & Cans',
    'Iced Blended (Coffee Based)',
    'Iced Blended (Non-Coffee Based)',
    'Smoothies & Milkshakes',
    'Alcoholic Drinks',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerOrdersScreen()),
                );
            },
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile & Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
            },
            ),
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search dishes, drinks, frappes, coffee...",
                prefixIcon: const Icon(Icons.search, color: AppColors.caramel),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categoryTabs.length,
              itemBuilder: (context, index) {
                final cat = _categoryTabs[index];
                final isSelected = _selectedCategory.toLowerCase() == (cat['title'] as String).toLowerCase();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['title'];
                      _selectedBeverageSubCategory = 'All';
                    });
                  },
                  child: Container(
                    width: 78,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.caramel : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.caramel : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            size: 22,
                            color: isSelected ? Colors.white : AppColors.espresso,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? AppColors.caramel : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedCategory == 'Beverages') ...[
            Container(
              height: 38,
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _beverageSubCategories.length,
                itemBuilder: (context, index) {
                  final sub = _beverageSubCategories[index];
                  final isSubSelected = _selectedBeverageSubCategory == sub;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(sub, style: TextStyle(fontSize: 11, fontWeight: isSubSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSubSelected,
                      selectedColor: AppColors.espresso,
                      labelStyle: TextStyle(color: isSubSelected ? Colors.white : AppColors.espresso),
                      backgroundColor: AppColors.surface,
                      onSelected: (val) {
                        if (val) setState(() => _selectedBeverageSubCategory = sub);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? "Search: '$_searchQuery'"
                        : (_selectedCategory == 'Beverages' && _selectedBeverageSubCategory != 'All')
                            ? "Beverages • $_selectedBeverageSubCategory"
                            : "Menu Items ($_selectedCategory)",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                ),
                if (_selectedCategory != 'All' || _searchQuery.isNotEmpty || _selectedBeverageSubCategory != 'All')
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedBeverageSubCategory = 'All';
                        _searchQuery = '';
                      });
                    },
                    child: const Text("Reset", style: TextStyle(color: AppColors.caramel, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.caramel));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("No items available in menu.", style: TextStyle(color: AppColors.textMuted)));
                }

                  final products = docs.map((doc) => Product.fromFirestore(doc)).where((p) {
                    // 1. Primary category match
                    final matchesCategory = _selectedCategory == 'All' ||
                        p.category.toLowerCase() == _selectedCategory.toLowerCase();

                    // 2. Beverage subcategory match (checks p.subCategory, not p.category!)
                    final matchesSubCategory = _selectedCategory != 'Beverages' ||
                        _selectedBeverageSubCategory == 'All' ||
                        p.subCategory.trim().toLowerCase() == _selectedBeverageSubCategory.trim().toLowerCase();

                    // 3. Search query match
                    final matchesSearch = _searchQuery.isEmpty ||
                        p.productName.toLowerCase().contains(_searchQuery) ||
                        p.description.toLowerCase().contains(_searchQuery) ||
                        p.subCategory.toLowerCase().contains(_searchQuery);

                    return matchesCategory && matchesSubCategory && matchesSearch;
                  }).toList();

                if (products.isEmpty) {
                  return const Center(child: Text("No matching items found.", style: TextStyle(color: AppColors.textMuted)));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return Card(
                      color: AppColors.surface,
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(product: item, onAddToCart: _addToCart),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 75,
                                    height: 75,
                                    color: AppColors.latte,
                                    child: const Icon(Icons.restaurant_menu, color: AppColors.caramel),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.espresso),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₱${item.price.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.caramel),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.espresso, size: 28),
                                onPressed: () {
                                  _addToCart(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.productName} added to tray!'),
                                      duration: const Duration(milliseconds: 900),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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