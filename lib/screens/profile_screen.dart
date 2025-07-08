import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_catring/screens/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data user yang akan dimuat dari SharedPreferences
  String namaUser = '';
  String emailUser = '';
  String phoneUser = '';
  String addressUser = '';
  String profileImageUrl = '';
  
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Fungsi untuk memuat data user dari SharedPreferences
  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        final userMap = jsonDecode(userData);
        setState(() {
          namaUser = userMap['name'] ?? 'User';
          emailUser = userMap['email'] ?? '';
          phoneUser = userMap['phone'] ?? '';
          addressUser = userMap['address'] ?? '';
          profileImageUrl = userMap['profile_image'] ?? '';
          isLoggedIn = true;
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoggedIn = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk logout - DIPERBAIKI
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Hapus semua data yang berkaitan dengan user
      await prefs.remove('user_data');
      await prefs.remove('auth_token');
      await prefs.remove('token'); // Tambahan jika ada variasi nama token
      await prefs.remove('is_logged_in'); // Jika ada flag login
      
      // Reset state lokal
      setState(() {
        namaUser = '';
        emailUser = '';
        phoneUser = '';
        addressUser = '';
        profileImageUrl = '';
        isLoggedIn = false;
      });
      
      // Kembali ke halaman login dan hapus semua route sebelumnya
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Tetap coba navigasi meskipun ada error
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  // Dialog konfirmasi logout - DIPERBAIKI
  void showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dismiss dengan tap di luar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog dulu
                await logout(); // Lalu jalankan logout
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isLoggedIn
              ? _buildNotLoggedInView()
              : _buildProfileView(),
    );
  }

  // Widget untuk tampilan ketika user belum login
  Widget _buildNotLoggedInView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan login untuk melihat profile Anda',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tampilan profile ketika user sudah login
  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Profile dengan foto dan nama
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // Informasi Personal
          _buildPersonalInfo(),
          const SizedBox(height: 24),
          
          // Menu Options
          _buildMenuOptions(),
          const SizedBox(height: 24),
          
          // Logout Button
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // Widget untuk header profile dengan foto dan nama
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGrey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: profileImageUrl.isNotEmpty
                  ? Image.network(
                      'http://192.168.1.10:8000/storage/$profileImageUrl',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Nama User
          Text(
            namaUser,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email User
          Text(
            emailUser,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk informasi personal
  Widget _buildPersonalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Email
          _buildInfoRow(Icons.email, 'Email', emailUser),
          const SizedBox(height: 12),
          
          // Phone
          if (phoneUser.isNotEmpty)
            _buildInfoRow(Icons.phone, 'Nomor Telepon', phoneUser),
          if (phoneUser.isNotEmpty) const SizedBox(height: 12),
          
          // Address
          if (addressUser.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Alamat', addressUser),
        ],
      ),
    );
  }

  // Widget untuk baris informasi
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Belum diisi' : value,
                style: TextStyle(
                  fontSize: 14,
                  color: value.isEmpty ? AppColors.grey : AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk menu options
  Widget _buildMenuOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
         _buildMenuItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    namaAwal: namaUser,
                    emailAwal: emailUser,
                  ),
                ),
              );
              
              // Reload data jika ada perubahan
              if (result == true) {
                loadUserData();
              }
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Riwayat Pesanan',
            onTap: () {
              // Navigate to order history screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Riwayat Pesanan - Coming Soon')),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () {
              // Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan - Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk item menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk divider menu
  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.lightGrey,
      indent: 56,
      endIndent: 16,
    );
  }

  // Widget untuk tombol logout - DIPERBAIKI
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}