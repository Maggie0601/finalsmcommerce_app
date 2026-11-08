import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../utils/colors.dart';

class CartScreen extends StatefulWidget {
  final Map<Product, int> cartItems;
  final VoidCallback onClearCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onClearCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _serviceType = 'Dine-in';
  final _tableOrAddressController = TextEditingController(text: 'Table 1');
  bool _isSubmitting = false;

  double get _totalPrice {
    double sum = 0.0;
    for (MapEntry<Product, int> entry in widget.cartItems.entries) {
      sum += entry.key.price * entry.value;
    }
    return sum;
  }

  Future<void> _submitOrder() async {
    if (widget.cartItems.isEmpty) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      String customerName = user?.email ?? 'Valued Customer';
      String customerPhone = 'N/A';

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          customerName = data['name'] ?? customerName;
          customerPhone = data['phone'] ?? customerPhone;
        }
      }

      // Strictly typed List of Maps required by Firestore
      final List<dynamic> itemsList = [];
      for (MapEntry<Product, int> entry in widget.cartItems.entries) {
        itemsList.add({
          'productName': entry.key.productName,
          'price': entry.key.price,
          'quantity': entry.value,
        });
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid ?? 'guest',
        'customerName': customerName,
        'customerPhone': customerPhone,
        'serviceType': _serviceType,
        'tableOrAddress': _tableOrAddressController.text.trim(),
        'items': itemsList,
        'total': _totalPrice,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      widget.onClearCart();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
            backgroundColor: AppColors.latte, // Changed from AppColors.surface
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Order Placed!",
            style: TextStyle(color: AppColors.espresso, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Your order is sent to Yeyi's kitchen!",
            ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.caramel, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _tableOrAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Order Summary"),
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text(
                "Your tray is empty.",
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        "Dining Option",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.espresso,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Dine-in', 'Takeout', 'Delivery'].map((type) {
                          final isSelected = _serviceType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              selectedColor: AppColors.caramel,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.espresso,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setState(() {
                                    _serviceType = type;
                                    if (type == 'Dine-in') _tableOrAddressController.text = 'Table 1';
                                    if (type == 'Takeout') _tableOrAddressController.text = 'Counter Pickup';
                                    if (type == 'Delivery') _tableOrAddressController.text = 'Tanay, Rizal';
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tableOrAddressController,
                        decoration: InputDecoration(
                          labelText: _serviceType == 'Dine-in'
                              ? 'Table Number'
                              : 'Delivery Address / Pickup Note',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const Divider(height: 32),
                      const Text(
                        "Items",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.espresso,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.cartItems.entries.map((entry) {
                        final Product product = entry.key;
                        final int qty = entry.value;
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              product.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('₱${product.price.toStringAsFixed(0)} x $qty'),
                            trailing: Text(
                              '₱${(product.price * qty).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.caramel,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.espresso,
                            ),
                          ),
                          Text(
                            '₱${_totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.caramel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.espresso,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitOrder,
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Confirm & Place Order",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}