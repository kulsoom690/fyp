import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartscalex/screens/eiditableprofile.dart' show EditableProfileScreen;
import 'package:smartscalex/services/imgbb_service.dart';
import 'package:smartscalex/theme/theme_provider.dart' show ThemeProvider;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  String? name;
  String? email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          profileImageUrl = data['photoURL'] ?? 'https://i.pravatar.cc/150?img=3';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditableProfileScreen()),
    );
    _loadUserData(); // Refresh after edit
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.purple),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(profileImageUrl!),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.teal,
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: _navigateToEditProfile,
                    child: const Text("Edit Profile", style: TextStyle(color: Colors.blue)),
                  ),
                  const Divider(height: 30),
                  _buildListTile(Icons.favorite, 'Favourites', () {}),
                  _buildListTile(Icons.download, 'Downloads', () {}),
                  const Divider(),
                  _buildListTile(Icons.language, 'Languages', () {}),
                  _buildListTile(Icons.location_on, 'Location', () {}),
                  _buildListTile(Icons.subscriptions, 'Subscription', () {}),
                  _buildListTile(Icons.display_settings, 'Display', () {}),
                  const Divider(),
                  _buildListTile(Icons.delete, 'Clear Cache', () {}),
                  _buildListTile(Icons.history, 'Clear History', () {}),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildListTile(
                      Icons.logout,
                      'Logout',
                      _logout,
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
