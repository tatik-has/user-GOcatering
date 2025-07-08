import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final String namaAwal;
  final String emailAwal;

  const EditProfileScreen({
    super.key,
    required this.namaAwal,
    required this.emailAwal,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController namaController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.namaAwal);
    emailController = TextEditingController(text: widget.emailAwal);
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void simpanProfile() {
    if (namaController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Email tidak boleh kosong')),
      );
      return;
    }

    Navigator.pop(context, {
      'name': namaController.text,
      'email': emailController.text,
      'password': passwordController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password (Biarkan kosong jika tidak diubah)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: simpanProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
