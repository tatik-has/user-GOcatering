import 'package:flutter/material.dart';
import 'package:go_catring/screens/home_screen.dart';
import 'package:go_catring/screens/katering_detail_screen.dart';
import 'package:go_catring/screens/login_screen.dart';
import 'package:go_catring/screens/register_screen.dart';
import 'package:go_catring/screens/profile_screen.dart';
import 'package:go_catring/screens/kuliner_screen.dart';
import 'package:go_catring/screens/splash_screen.dart';
import 'package:go_catring/screens/riwayat_pesanan_screen.dart';
import 'package:go_catring/screens/katering_screen.dart'; // <- Tambahan
import 'package:go_catring/models/menu_models.dart'; // Untuk Kuliner
import 'package:go_catring/models/katering_model.dart'; // <- Tambahan

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
        if (settings.name == '/kuliner') {
          final args = settings.arguments;
          if (args is Kuliner) {
            return MaterialPageRoute(
              builder: (context) => KulinerScreen(kuliner: args),
            );
          }
        }

        // (Opsional) Jika nanti buat halaman detail katering
        // if (settings.name == '/kateringDetail') {
        //   final args = settings.arguments;
        //   if (args is Katering) {
        //     return MaterialPageRoute(
        //       builder: (context) => KateringDetailScreen(katering: args),
        //     );
        //   }
        // }

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
