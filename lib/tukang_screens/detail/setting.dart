import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rampungin_id_userside/Auth_screens/login.dart';
import 'edit_profile.dart';
import 'ubahpassword.dart';

class Setting extends StatelessWidget {
  Setting({super.key});

  final logger = Logger();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header section with curved bottom
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3B950),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(200),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      15,
                      MediaQuery.of(context).padding.top + 20,
                      15,
                      100,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 27,
                            ),
                          ),
                        ),
                        const SizedBox(width: 26),
                        const Expanded(
                          child: Text(
                            'PENGATURAN',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Koulen',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings icon with overlap
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x40000000),
                                offset: Offset(0, 4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 66,
                            backgroundColor: Color(0xFFF3B950),
                            child: Icon(
                              Icons.settings,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings title
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: const Text(
                      'Pengaturan Aplikasi',
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Acme',
                      ),
                    ),
                  ),

                  // Content area with settings options
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF6E8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFF3B950),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(-3, -3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Account Settings
                              _buildSectionTitle('Akun'),
                              const SizedBox(height: 12),
                              _buildSettingItem(
                                icon: Icons.person_outline,
                                title: 'Edit Profil',
                                subtitle: 'Ubah informasi profil Anda',
                                onTap: () => _navigateToEditProfile(context),
                              ),

                              _buildSettingItem(
                                icon: Icons.lock_outline,
                                title: 'Ubah Password',
                                subtitle: 'Ganti kata sandi akun',
                                onTap: () => _navigateToChangePassword(context),
                              ),

                              const SizedBox(height: 24),

                              // Support
                              _buildSectionTitle('Bantuan & Dukungan'),
                              const SizedBox(height: 12),
                              _buildSettingItem(
                                icon: Icons.help_outline,
                                title: 'Pusat Bantuan',
                                subtitle: 'Dapatkan bantuan dan panduan',
                                onTap: () {
                                  logger.i('Pusat Bantuan tapped');
                                },
                              ),
                              _buildSettingItem(
                                icon: Icons.description_outlined,
                                title: 'Syarat & Ketentuan',
                                subtitle: 'Baca syarat penggunaan',
                                onTap: () {
                                  logger.i('Syarat & Ketentuan tapped');
                                },
                              ),
                              _buildSettingItem(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Kebijakan Privasi',
                                subtitle: 'Baca kebijakan privasi kami',
                                onTap: () {
                                  logger.i('Kebijakan Privasi tapped');
                                },
                              ),
                              _buildSettingItem(
                                icon: Icons.contact_support_outlined,
                                title: 'Hubungi Kami',
                                subtitle: 'Kontak customer service',
                                onTap: () {
                                  logger.i('Hubungi Kami tapped');
                                },
                              ),

                              const SizedBox(height: 24),

                              // Account Actions
                              _buildSectionTitle('Tindakan Akun'),
                              const SizedBox(height: 12),
                              _buildSettingItem(
                                icon: Icons.logout,
                                title: 'Keluar',
                                subtitle: 'Keluar dari akun Anda',
                                isDestructive: true,
                                onTap: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                              _buildSettingItem(
                                icon: Icons.delete_outline,
                                title: 'Hapus Akun',
                                subtitle: 'Hapus akun secara permanen',
                                isDestructive: true,
                                onTap: () {
                                  _showDeleteAccountDialog(context);
                                },
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom spacing
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFF3B950),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Acme',
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : const Color(0xFFF3B950).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFFF3B950),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : const Color(0xFF333333),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color:
                isDestructive
                    ? Colors.red.withValues(alpha: 0.7)
                    : const Color(0xFF666666),
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDestructive ? Colors.red : const Color(0xFF666666),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfile()),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UbahPassword()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar Akun'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle logout logic
                  logger.i('User logged out');
                  // Navigate to login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Akun'),
            content: const Text(
              'Tindakan ini akan menghapus akun Anda secara permanen. '
              'Semua data akan hilang dan tidak dapat dikembalikan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle delete account logic
                  logger.i('Account deleted');
                  // Navigate to login screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
