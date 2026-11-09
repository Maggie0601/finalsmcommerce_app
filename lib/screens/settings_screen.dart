import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _promotionalAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("App Settings"),
        backgroundColor: AppColors.espresso,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Preferences",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.espresso),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Live Order Status Alerts"),
                  subtitle: const Text("Notify when kitchen prepares or delivers order"),
                  value: _orderNotifications,
                  activeColor: AppColors.caramel,
                  onChanged: (val) => setState(() => _orderNotifications = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Special Promotions"),
                  subtitle: const Text("Get updates on weekend platters and branch discounts"),
                  value: _promotionalAlerts,
                  activeColor: AppColors.caramel,
                  onChanged: (val) => setState(() => _promotionalAlerts = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Branch Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.espresso),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.store, color: AppColors.espresso),
                  title: Text("Yeyi's Pizzeria & Café"),
                  subtitle: Text("KM61 Malapapaya St., Tanay, Rizal"),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.access_time, color: AppColors.espresso),
                  title: Text("Operating Hours"),
                  subtitle: Text("Mon-Fri: 6:00 AM - 2:00 AM\nSat-Sun: 5:00 AM - 2:00 AM"),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone, color: AppColors.espresso),
                  title: Text("Contact Number"),
                  subtitle: Text("0981 476 3388"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
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
    );
  }
}