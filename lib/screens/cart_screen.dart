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
  final String _paymentMethod = 'Cash / Cash on Delivery (COD)';
  String _discountType = 'None';
  final _idNumberController = TextEditingController();
  final _tableOrAddressController = TextEditingController(text: 'Table 1');
  bool _isSubmitting = false;

  double get _subtotal {
    double sum = 0.0;
    widget.cartItems.forEach((product, qty) {
      sum += product.price * qty;
    });
    return sum;
  }

  double get _discountRate {
    switch (_discountType) {
      case 'Senior Citizen (20%)':
      case 'PWD (20%)':
        return 0.20;
      default:
        return 0.0;
    }
  }

  double get _discountAmount => _subtotal * _discountRate;
  double get _finalTotal => _subtotal - _discountAmount;

  void _increaseQuantity(Product product) {
    setState(() {
      widget.cartItems[product] = (widget.cartItems[product] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(Product product) {
    setState(() {
      final current = widget.cartItems[product] ?? 1;
      if (current > 1) {
        widget.cartItems[product] = current - 1;
      } else {
        widget.cartItems.remove(product);
      }
    });
  }

  void _removeItem(Product product) {
    setState(() {
      widget.cartItems.remove(product);
    });
  }

  Future<void> _submitOrder() async {
    if (widget.cartItems.isEmpty) return;

    if (_discountRate > 0 && _idNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Senior/PWD ID Number for verification.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      String customerName = user?.email ?? 'Valued Customer';
      String customerPhone = 'N/A';

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          customerName = data['name'] ?? customerName;
          customerPhone = data['phone'] ?? customerPhone;
        }
      }

      final List<dynamic> itemsList = [];
      widget.cartItems.forEach((product, qty) {
        itemsList.add({
          'productName': product.productName,
          'price': product.price,
          'quantity': qty,
        });
      });

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid ?? 'guest',
        'customerName': customerName,
        'customerPhone': customerPhone,
        'serviceType': _serviceType,
        'tableOrAddress': _tableOrAddressController.text.trim(),
        'paymentMethod': _paymentMethod,
        'discountType': _discountType,
        'discountId': _idNumberController.text.trim(),
        'subtotal': _subtotal,
        'discountAmount': _discountAmount,
        'total': _finalTotal,
        'items': itemsList,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      widget.onClearCart();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Order Placed!", style: TextStyle(color: AppColors.espresso, fontWeight: FontWeight.bold)),
          content: Text(
            "Your order has been sent to Yeyi's kitchen!\n\nPayment Mode: Cash / COD.",
            style: const TextStyle(color: AppColors.espresso),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: AppColors.caramel, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _tableOrAddressController.dispose();
    _idNumberController.dispose();
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
              child: Text("Your tray is empty.", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Dining Option
                      const Text("Dining Option", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
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
                      const SizedBox(height: 10),
                      TextField(
                        controller: _tableOrAddressController,
                        decoration: InputDecoration(
                          labelText: _serviceType == 'Dine-in' ? 'Table Number' : 'Delivery Address / Pickup Note',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const Divider(height: 28),

                      // Payment Method Notice
                      const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.caramel.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_outlined, color: AppColors.caramel, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _serviceType == 'Delivery' ? 'Cash on Delivery (COD)' : 'Cash on Counter / Cash on Hand',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Notice: All transactions are currently accepted via Cash / COD only.',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 28),

                      // Special Discounts (Senior & PWD Only)
                      const Text("Special Discount", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _discountType,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: ['None', 'Senior Citizen (20%)', 'PWD (20%)']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _discountType = val);
                        },
                      ),
                      if (_discountRate > 0) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _idNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Senior / PWD ID Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const Divider(height: 28),

                      // Tray items with edit options
                      const Text("Tray Items (Tap - / + to Edit)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
                      const SizedBox(height: 8),
                      ...widget.cartItems.entries.map((entry) {
                        final product = entry.key;
                        final qty = entry.value;
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('₱${product.price.toStringAsFixed(0)} each', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.caramel, size: 22),
                                      onPressed: () => _decreaseQuantity(product),
                                    ),
                                    Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: AppColors.caramel, size: 22),
                                      onPressed: () => _increaseQuantity(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => _removeItem(product),
                                    ),
                                  ],
                                ),
                              ],
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
                          const Text("Subtotal:", style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
                          Text('₱${_subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (_discountRate > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Discount ($_discountType):", style: const TextStyle(fontSize: 14, color: Colors.green)),
                            Text('-₱${_discountAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Payable", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.espresso)),
                          Text('₱${_finalTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.caramel)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: _isSubmitting ? null : _submitOrder,
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Confirm & Place Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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