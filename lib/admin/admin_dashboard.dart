import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../screens/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Pizza';

  final List<String> _categories = [
    'Pizza',
    'Pasta',
    'Main Dishes',
    'Appetizers',
    'Beverages',
  ];

  Future<void> _addProduct() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out product name and price.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'productName': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descController.text.trim(),
        'imageUrl': _imageController.text.trim().isEmpty
            ? 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg'
            : _imageController.text.trim(),
        'stock': int.tryParse(_stockController.text.trim()) ?? 50,
        'category': _selectedCategory,
      });

      _nameController.clear();
      _priceController.clear();
      _descController.clear();
      _imageController.clear();
      _stockController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  Future<void> _deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  void _showAddProductBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Menu Item",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.espresso,
                ),
              ),
              const SizedBox(height: 12),
              _buildAddProductFormFields(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.espresso,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addProduct();
                  },
                  child: const Text('Save Product to Menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProductFormFields() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Price (₱)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descController,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _imageController,
          decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stock Quantity', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Yeyi's Admin Portal"),
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
        actions: [
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
      floatingActionButton: (isMobile && _selectedIndex == 0)
          ? FloatingActionButton(
              backgroundColor: AppColors.caramel,
              onPressed: _showAddProductBottomSheet,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: AppColors.caramel,
              unselectedItemColor: AppColors.textMuted,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.fastfood),
                  label: 'Inventory',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
              ],
            )
          : null,
      body: isMobile
          ? (_selectedIndex == 0 ? _buildMobileProductList() : _buildOrderMonitoring())
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
                  backgroundColor: AppColors.surface,
                  selectedIconTheme: const IconThemeData(color: AppColors.caramel),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.caramel,
                    fontWeight: FontWeight.bold,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.fastfood),
                      label: Text('Product Management'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long),
                      label: Text('Order Monitoring'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _selectedIndex == 0 ? _buildDesktopProductManagement() : _buildOrderMonitoring(),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileProductList() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: AppColors.surface,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Menu Inventory",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.espresso,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text("No products found in menu."));
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.latte,
                            backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                            onBackgroundImageError: (_, __) {},
                          ),
                          title: Text(
                            data['productName'] ?? 'Unnamed',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${data['category'] ?? ''} • ₱${data['price']} • Stock: ${data['stock']}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteProduct(doc.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopProductManagement() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 360,
            child: Card(
              color: AppColors.surface,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const Text(
                      "Add New Menu Item",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.espresso,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAddProductFormFields(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.espresso,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _addProduct,
                      child: const Text('Save Product to Menu'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(child: _buildMobileProductList()),
        ],
      ),
    );
  }

  Widget _buildOrderMonitoring() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: AppColors.surface,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Live Kitchen & Counter Orders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.espresso,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text("No customer orders placed yet."));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final status = data['status'] ?? 'Pending';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${data['customerName'] ?? 'Guest'} (${data['serviceType'] ?? 'Dine-in'})",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: ['Pending', 'Processing', 'Delivered'].contains(status)
                                          ? status
                                          : 'Pending',
                                      items: ['Pending', 'Processing', 'Delivered']
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onChanged: (newStatus) {
                                        if (newStatus != null) {
                                          _updateOrderStatus(doc.id, newStatus);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  "Table/Address: ${data['tableOrAddress'] ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Total: ₱${data['total']} • Status: $status",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.caramel,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}