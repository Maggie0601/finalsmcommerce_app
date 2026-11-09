import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  int _getStatusStep(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 1;
      case 'delivered':
      case 'archived':
        return 2;
      case 'pending':
      default:
        return 0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'archived':
        return Colors.grey;
      case 'pending':
      default:
        return AppColors.caramel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Track My Orders"),
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
      ),
body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.uid ?? 'guest')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.caramel));
          }
          final rawDocs = snapshot.data?.docs ?? [];
          if (rawDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    "You haven't placed any orders yet.",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Sort orders: most recent purchase at the top
          final docs = List<QueryDocumentSnapshot>.from(rawDocs)
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['timestamp'] as Timestamp?;
              final bTime = bData['timestamp'] as Timestamp?;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return -1;
              if (bTime == null) return 1;
              return bTime.compareTo(aTime); // Descending (latest first)
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final status = (data['status'] ?? 'Pending').toString();
              final currentStep = _getStatusStep(status);
              final items = (data['items'] as List?) ?? [];

              return Card(
                color: AppColors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Service Type & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${data['serviceType'] ?? 'Dine-in'} (${data['tableOrAddress'] ?? 'Table 1'})",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.espresso),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStatusColor(status)),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Real-Time Progress Stepper
                      Row(
                        children: [
                          _buildStepIndicator(
                            title: 'Received',
                            icon: Icons.receipt,
                            isActive: currentStep >= 0,
                            isDone: currentStep > 0,
                          ),
                          _buildStepLine(isActive: currentStep >= 1),
                          _buildStepIndicator(
                            title: 'Preparing',
                            icon: Icons.soup_kitchen,
                            isActive: currentStep >= 1,
                            isDone: currentStep > 1,
                          ),
                          _buildStepLine(isActive: currentStep >= 2),
                          _buildStepIndicator(
                            title: 'Delivered',
                            icon: Icons.check_circle,
                            isActive: currentStep >= 2,
                            isDone: currentStep >= 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Products Ordered List
                      const Text(
                        "Order Summary:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.espresso),
                      ),
                      const SizedBox(height: 4),
                      ...items.map((item) {
                        final itemMap = item as Map<String, dynamic>;
                        final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                        final qty = (itemMap['quantity'] as num?)?.toInt() ?? 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("• ${itemMap['productName']} (x$qty)", style: const TextStyle(fontSize: 13)),
                              Text("₱${(price * qty).toStringAsFixed(0)}", style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 10),

                      // Payment info & Total Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Paid via ${data['paymentMethod'] ?? 'Cash'}",
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          Row(
                            children: [
                              const Text("Total: ", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
                              Text(
                                "₱${data['total'] ?? 0}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.caramel),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator({
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isDone,
  }) {
    final color = isActive ? (isDone ? Colors.green : AppColors.caramel) : AppColors.border;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.espresso : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Container(
      width: 32,
      height: 3,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? Colors.green : AppColors.border,
    );
  }
}