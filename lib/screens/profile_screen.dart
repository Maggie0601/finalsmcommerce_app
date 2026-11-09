import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _notifications = true;
  bool _isLoading = true;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _role = data['role'] ?? 'user';
        }
      } catch (e) {
        debugPrint("Error loading user profile: $e");
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Account & Settings"),
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.caramel))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.latte,
                    child: Icon(
                      _role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                      size: 44,
                      color: AppColors.caramel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.email ?? 'Unknown User',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.espresso),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _role == 'admin' ? Colors.red.withOpacity(0.12) : AppColors.sageLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _role == 'admin' ? Colors.red : AppColors.sage,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.caramel, foregroundColor: Colors.white),
                              onPressed: _saveProfile,
                              child: const Text('Update Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("App & Branch Settings", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.espresso)),
                          SwitchListTile(
                            title: const Text("Order Notifications"),
                            subtitle: const Text("Receive notifications for status updates"),
                            value: _notifications,
                            activeColor: AppColors.caramel,
                            onChanged: (val) => setState(() => _notifications = val),
                          ),
                          const Divider(),
                          const ListTile(
                            leading: Icon(Icons.store, color: AppColors.espresso),
                            title: Text("Yeyi's Pizzeria & Café (Tanay Branch)"),
                            subtitle: Text("KM61 Malapapaya St., Tanay, Rizal"),
                          ),
                          const ListTile(
                            leading: Icon(Icons.phone, color: AppColors.espresso),
                            title: Text("Branch Contact"),
                            subtitle: Text("0981 476 3388"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}