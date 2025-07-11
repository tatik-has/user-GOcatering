import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6AB04C);
  static const Color primaryDark = Color(0xFF4F7942);
  static const Color secondary = Color(0xFF2F3542);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    color: AppColors.grey,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );
}

// Tambahkan class AppConstants ini
class AppConstants {
  // Ganti dengan URL server Anda yang sebenarnya
  static const String baseUrl = 'https://e18c87dbbcc7.ngrok-free.app'; // Contoh URL
  static const String imageUrl = 'https://e18c87dbbcc7.ngrok-free.app'; // Untuk gambar
  
  // Jika server online, contoh:
  // static const String baseUrl = 'https://your-domain.com';
  // static const String imageUrl = 'https://your-domain.com';
  
  // Timeout untuk request
  static const Duration requestTimeout = Duration(seconds: 30);

  static var apiUrl;
}