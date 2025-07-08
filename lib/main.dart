import 'package:flutter/material.dart';
import 'package:go_catring/screens/home_screen.dart';
import 'package:go_catring/screens/login_screen.dart';
import 'package:go_catring/screens/register_screen.dart';
import 'package:go_catring/screens/profile_screen.dart';
import 'package:go_catring/screens/kuliner_screen.dart';
import 'package:go_catring/screens/splash_screen.dart';
import 'package:go_catring/screens/riwayat_pesanan_screen.dart';
import 'package:go_catring/models/menu_models.dart'; // Tambahkan ini untuk Kuliner

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Catring',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/Riwayat': (context) => const RiwayatPesananScreen(),
      },
      onGenerateRoute: (settings) {
        // Pastikan args bertipe Kuliner
        if (settings.name == '/kuliner') {
          final args = settings.arguments;
          if (args is Kuliner) {
            return MaterialPageRoute(
              builder: (context) => KulinerScreen(kuliner: args),
            );
          } else {
            // Penanganan jika argumen tidak sesuai
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
          }
        }

        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}
