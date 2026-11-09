import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../services/seed_full_menu.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _orderTab = 'Pending'; // Pending, Processing, Delivered, Archive
  String _adminSearchQuery = '';
  final _adminSearchController = TextEditingController();

  // Active Menu Category Filter
  String _selectedMenuCategory = 'All';

  // Controllers for Adding/Editing Products
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Pizza';

  final List<String> _categories = [
    'Pizza',
    'Pasta',
    'Sizzling Plates',
    'Main Dishes',
    'Breakfast',
    'Appetizers',
    'Beverages',
  ];

  @override
  void dispose() {
    _adminSearchController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // --- PRODUCT CRUD ---
  Future<void> _addProduct() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'productName': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descController.text.trim(),
        'imageUrl': _imageController.text.trim().isEmpty
            ? 'https://picsum.photos/300/200?random=1'
            : _imageController.text.trim(),
        'stock': int.tryParse(_stockController.text.trim()) ?? 50,
        'category': _selectedCategory,
        'isAvailable': true,
      });

      _clearForm();
      if (!mounted) return;
      Navigator.pop(context);
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

  Future<void> _updateProduct(
    String docId,
    String name,
    String price,
    String desc,
    String image,
    String stock,
    String category,
  ) async {
    if (name.trim().isEmpty || price.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'productName': name.trim(),
        'price': double.tryParse(price.trim()) ?? 0.0,
        'description': desc.trim(),
        'imageUrl': image.trim(),
        'stock': int.tryParse(stock.trim()) ?? 0,
        'category': category,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated & restocked successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  Future<void> _deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _descController.clear();
    _imageController.clear();
    _stockController.clear();
  }

  // --- ADD / EDIT PRODUCT DIALOG ---
  void _showProductDialog({String? docId, Map<String, dynamic>? existingData}) {
    final nameController = TextEditingController(text: existingData?['productName'] ?? '');
    final priceController = TextEditingController(text: existingData?['price']?.toString() ?? '');
    final descController = TextEditingController(text: existingData?['description'] ?? '');
    final imageController = TextEditingController(text: existingData?['imageUrl'] ?? '');
    final stockController = TextEditingController(text: existingData?['stock']?.toString() ?? '50');
    String dialogCategory = existingData?['category'] ?? 'Pizza';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            docId == null ? "Add New Menu Item" : "Edit Item & Restock",
            style: const TextStyle(color: AppColors.espresso, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (₱)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock Quantity', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _categories.contains(dialogCategory) ? dialogCategory : 'Pizza',
                    items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setDialogState(() => dialogCategory = val!),
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.espresso,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (docId == null) {
                  _nameController.text = nameController.text;
                  _priceController.text = priceController.text;
                  _descController.text = descController.text;
                  _imageController.text = imageController.text;
                  _stockController.text = stockController.text;
                  _selectedCategory = dialogCategory;
                  _addProduct();
                } else {
                  _updateProduct(
                    docId,
                    nameController.text,
                    priceController.text,
                    descController.text,
                    imageController.text,
                    stockController.text,
                    dialogCategory,
                  );
                }
              },
              child: Text(docId == null ? 'Save Product' : 'Update & Restock'),
            ),
          ],
        ),
      ),
    );
  }

  // --- ORDER STATUS UPDATES ---
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Yeyi's Admin Portal"),
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Complete Restaurant Menu',
            onPressed: () async {
              try {
                await seedFullYeyisMenu();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All Menu Categories seeded to Firestore!')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Seeding failed: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Admin Profile & Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
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
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) => setState(() {
              _selectedIndex = index;
              _adminSearchController.clear();
              _adminSearchQuery = '';
            }),
            backgroundColor: AppColors.surface,
            selectedIconTheme: const IconThemeData(color: AppColors.caramel),
            selectedLabelTextStyle: const TextStyle(color: AppColors.caramel, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.fastfood), label: Text('Menu Inventory')),
              NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Orders & Archive')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _selectedIndex == 0 ? _buildProductManagement() : _buildOrderMonitoring(),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.caramel,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showProductDialog(),
            )
          : null,
    );
  }

  // --- PRODUCT MANAGEMENT VIEW WITH CATEGORIZATION & SEARCH ---
  Widget _buildProductManagement() {
    final allCategoryFilters = ['All', ..._categories];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Yeyi's Active Menu Inventory",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.espresso),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _adminSearchController,
                  onChanged: (val) => setState(() => _adminSearchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search dishes or categories...",
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.caramel),
                    suffixIcon: _adminSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _adminSearchController.clear();
                              setState(() => _adminSearchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Menu Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: allCategoryFilters.map((cat) {
                final isSelected = _selectedMenuCategory.toLowerCase() == cat.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.caramel,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.espresso,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedMenuCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Stream of Products filtered by Category and Search
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.caramel));
                final docs = snapshot.data!.docs;

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['productName'] ?? '').toString().toLowerCase();
                  final cat = (data['category'] ?? '').toString().toLowerCase();

                  final matchesCategory = _selectedMenuCategory == 'All' ||
                      cat == _selectedMenuCategory.toLowerCase();
                  final matchesSearch = _adminSearchQuery.isEmpty ||
                      name.contains(_adminSearchQuery) ||
                      cat.contains(_adminSearchQuery);

                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      "No products found in '$_selectedMenuCategory'.",
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                    ),
                  );
                }

                return ListView(
                  children: filteredDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['imageUrl'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: AppColors.latte,
                              child: const Icon(Icons.fastfood, color: AppColors.caramel),
                            ),
                          ),
                        ),
                        title: Text(data['productName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${data['category']}'
                            '${(data['subCategory'] != null && data['subCategory'].toString().isNotEmpty) ? ' • ${data['subCategory']}' : ''}'
                            ' • ₱${data['price']} • Stock: ${data['stock']}',
                            ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.caramel),
                              tooltip: 'Edit & Restock',
                              onPressed: () => _showProductDialog(docId: doc.id, existingData: data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Product',
                              onPressed: () => _deleteProduct(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ORDER MONITORING & ARCHIVE VIEW WITH SEARCH ---
  Widget _buildOrderMonitoring() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Live Kitchen Orders & Archive",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.espresso),
              ),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _adminSearchController,
                  onChanged: (val) => setState(() => _adminSearchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search customer, table, payment...",
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.caramel),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Order Tabs (Pending, Processing, Delivered, Archive)
          Row(
            children: ['Pending', 'Processing', 'Delivered', 'Archive'].map((tab) {
              final isSelected = _orderTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(tab),
                  selected: isSelected,
                  selectedColor: AppColors.caramel,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.espresso,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _orderTab = tab);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.caramel));
                final rawDocs = snapshot.data!.docs;

                // Sort: Most recent orders on top
                final sortedDocs = List<QueryDocumentSnapshot>.from(rawDocs)
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['timestamp'] as Timestamp?;
                    final bTime = bData['timestamp'] as Timestamp?;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return -1;
                    if (bTime == null) return 1;
                    return bTime.compareTo(aTime); // Descending
                  });

                // Filter by tab and search
                final filteredDocs = sortedDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Pending';
                  final matchesTab = _orderTab == 'Archive' ? status == 'Archived' : status == _orderTab;

                  final customer = (data['customerName'] ?? '').toString().toLowerCase();
                  final payment = (data['paymentMethod'] ?? '').toString().toLowerCase();
                  final table = (data['tableOrAddress'] ?? '').toString().toLowerCase();

                  final matchesSearch = _adminSearchQuery.isEmpty ||
                      customer.contains(_adminSearchQuery) ||
                      payment.contains(_adminSearchQuery) ||
                      table.contains(_adminSearchQuery);

                  return matchesTab && matchesSearch;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text("No orders found under '$_orderTab'."));
                }

                return ListView(
                  children: filteredDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'Pending';
                    final items = (data['items'] as List?) ?? [];

                    return Card(
                      color: AppColors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Customer Name and Total Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Customer: ${data['customerName'] ?? 'Guest'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.espresso,
                                  ),
                                ),
                                Text(
                                  "₱${data['total'] ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.caramel,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Service: ${data['serviceType'] ?? 'Dine-in'} (${data['tableOrAddress'] ?? 'N/A'})"),
                            Text("Payment: ${data['paymentMethod'] ?? 'Cash'} • Discount: ${data['discountType'] ?? 'None'}"),
                            Text("Contact: ${data['customerPhone'] ?? 'N/A'}"),
                            const Divider(height: 20),

                            // 2. Products Ordered List
                            const Text(
                              "Products Ordered:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.espresso,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (items.isNotEmpty)
                              ...items.map((item) {
                                final itemMap = item as Map<String, dynamic>;
                                final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                                final qty = (itemMap['quantity'] as num?)?.toInt() ?? 1;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "• ${itemMap['productName'] ?? 'Item'} (x$qty)",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      Text(
                                        "₱${(price * qty).toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                            else
                              const Text(
                                "No item details found.",
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            const Divider(height: 20),

                            // 3. Status Progression & Archive Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Status: $status", style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (_orderTab != 'Archive')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButton<String>(
                                        value: ['Pending', 'Processing', 'Delivered'].contains(status)
                                            ? status
                                            : 'Pending',
                                        items: ['Pending', 'Processing', 'Delivered'].map((s) {
                                          return DropdownMenuItem(value: s, child: Text(s));
                                        }).toList(),
                                        onChanged: (newStatus) {
                                          if (newStatus != null) {
                                            _updateOrderStatus(doc.id, newStatus);
                                          }
                                        },
                                      ),
                                      if (status == 'Delivered') ...[
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.espresso,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          ),
                                          icon: const Icon(Icons.archive, size: 14),
                                          label: const Text('Archive', style: TextStyle(fontSize: 12)),
                                          onPressed: () => _updateOrderStatus(doc.id, 'Archived'),
                                        ),
                                      ],
                                    ],
                                  )
                                else
                                  const Text(
                                    "Archived Record",
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}