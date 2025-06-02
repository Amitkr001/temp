import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A192F),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Color(0xFFE6F1FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF64FFDA),
                child: Icon(Icons.person, size: 50, color: Color(0xFF0A192F)),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'John Doe',
                style: const TextStyle(
                  color: Color(0xFFE6F1FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'john.doe@example.com',
                style: const TextStyle(color: Color(0xFF8892B0), fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildProfileSection(
                title: 'Account Settings',
                children: [
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileSection(
                title: 'App Settings',
                children: [
                  _buildSettingItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.storage_outlined,
                    title: 'Storage',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileSection(
                title: 'Support',
                children: [
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: _logout,
                    isLogout: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth'); // Make sure /auth route is defined
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE6F1FF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x1A0A192F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : const Color(0xFF64FFDA),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isLogout ? Colors.red : const Color(0xFFE6F1FF),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (!isLogout)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8892B0),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
