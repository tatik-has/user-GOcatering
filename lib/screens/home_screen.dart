// home_screen.dart (your main file)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/product_service.dart';
import '../models/menu_models.dart';
import 'package:go_catring/screens/kuliner_screen.dart';
import '../utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String namaUser = '';
  String keyword = '';

  // New list for all menu items
  List<Menu> allMenuItems = [];

  // Lists for specific categories, now derived from allMenuItems
  List<Kuliner> listKuliner = [];
  List<PaketBulanan> listPaketBulanan = [];
  List<Katering> listKatering = [];

  // Loading states
  bool isLoadingAllMenu = true; // Use one loading state for the main fetch
  // Error states
  String? errorMessageAllMenu;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadAllMenuData(); // Call the new loading method
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      final userMap = jsonDecode(userData);
      setState(() {
        namaUser = userMap['name'] ?? 'User';
      });
    }
  }

  // New function to load all menu data from the /api/menu endpoint
  Future<void> loadAllMenuData() async {
    setState(() {
      isLoadingAllMenu = true;
      errorMessageAllMenu = null;
    });

    final result = await ProductService.getMenu();

    setState(() {
      isLoadingAllMenu = false;
      if (result['success']) {
        allMenuItems = result['data'] as List<Menu>; // Cast to List<Menu>
        _filterMenuItems(); // Filter into specific lists
      } else {
        errorMessageAllMenu = result['message'];
        allMenuItems = [];
        listKuliner = [];
        listPaketBulanan = [];
        listKatering = [];
      }
    });
  }

  // Function to filter the fetched menu items into specific categories
  void _filterMenuItems() {
    listKuliner =
        allMenuItems
            .where((menu) => menu.kategoriUtama == 'kuliner')
            .map(
              (menu) => Kuliner.fromJson(menu.toJson()),
            ) // Re-create as Kuliner
            .toList();

    listPaketBulanan =
        allMenuItems
            .where((menu) => menu.kategoriUtama == 'paket_bulanan')
            .map(
              (menu) => PaketBulanan.fromJson(menu.toJson()),
            ) // Re-create as PaketBulanan
            .toList();

    listKatering =
        allMenuItems
            .where((menu) => menu.kategoriUtama == 'katering')
            .map(
              (menu) => Katering.fromJson(menu.toJson()),
            ) // Re-create aRs Katering
            .toList();
  }

  Future<void> _refreshData() async {
    await loadAllMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 24),
                // Display loading/error for all sections based on one state
                if (isLoadingAllMenu)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessageAllMenu != null)
                  Center(
                    child: Text(
                      'Error: $errorMessageAllMenu',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else ...[
                  _buildKulinerSection(),
                  const SizedBox(height: 24),
                  _buildPaketBulananSection(),
                  const SizedBox(height: 24),
                  _buildKateringSection(),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- Widget Builders (no significant changes here, as they now use the filtered lists) ---

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.lightGrey,
          child: Icon(Icons.person, color: AppColors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $namaUser',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
              const Text('Temukan Seleramu,', style: AppTextStyles.heading),
              const Text('Gelar Piringmu', style: AppTextStyles.heading),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.chat, color: AppColors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  keyword = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Mau makan apa hari ini?',
                border: InputBorder.none,
                hintStyle: AppTextStyles.subheading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKulinerSection() {
    // No more individual loading/error states here, rely on isLoadingAllMenu
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Kuliner', style: AppTextStyles.heading)],
        ),
        const SizedBox(height: 16),
        SizedBox(height: 100, child: _buildKulinerContent()),
      ],
    );
  }

  Widget _buildKulinerContent() {
    // Filter based on keyword
    List<Kuliner> hasilCari =
        keyword.isEmpty
            ? listKuliner
            : listKuliner
                .where(
                  (kuliner) => kuliner.nama.toLowerCase().contains(
                    keyword.toLowerCase(),
                  ),
                )
                .toList();

    if (hasilCari.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada hasil pencarian',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: hasilCari.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index == hasilCari.length - 1 ? 0 : 12,
          ),
          child: _buildKulinerItem(hasilCari[index]),
        );
      },
    );
  }

  Widget _buildKulinerItem(Kuliner kuliner) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KulinerScreen(kuliner: kuliner),
          ),
        );
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (kuliner.gambar?.isNotEmpty ?? false)
                    ? Image.network(
                        '${AppConstants.imageUrl}/storage/${kuliner.gambar}',
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.restaurant, color: Colors.orange, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kuliner.nama,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaketBulananSection() {
    // No more individual loading/error states here
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Paket Bulanan', style: AppTextStyles.heading)],
        ),
        const SizedBox(height: 16),
        SizedBox(height: 220, child: _buildPaketBulananContent()),
      ],
    );
  }

  Widget _buildPaketBulananContent() {
    if (listPaketBulanan.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada paket bulanan tersedia',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: listPaketBulanan.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index == listPaketBulanan.length - 1 ? 0 : 12,
          ),
          child: SizedBox(
            width: 180,
            child: _buildPaketCard(listPaketBulanan[index]),
          ),
        );
      },
    );
  }

  Widget _buildPaketCard(PaketBulanan paket) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  (paket.gambar?.isNotEmpty ?? false)
                      ? Image.network(
                        '${AppConstants.imageUrl}/storage/${paket.gambar}',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.fastfood,
                              color: AppColors.grey,
                              size: 40,
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Icon(
                          Icons.fastfood,
                          color: AppColors.grey,
                          size: 40,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            paket.nama,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            paket.harga,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 14),
              const SizedBox(width: 4),
              Text(paket.rating, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKateringSection() {
    // No more individual loading/error states here
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Katering', style: AppTextStyles.heading)],
        ),
        const SizedBox(height: 16),
        _buildKateringContent(),
      ],
    );
  }

  Widget _buildKateringContent() {
    if (listKatering.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada katering tersedia',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      );
    }

    return Column(
      children:
          listKatering
              .map(
                (katering) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildKateringCard(katering),
                ),
              )
              .toList(),
    );
  }

  Widget _buildKateringCard(Katering katering) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  katering.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  katering.harga,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(katering.rating, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  (katering.gambar?.isNotEmpty ?? false)
                      ? Image.network(
                        '${AppConstants.imageUrl}/storage/${katering.gambar}',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_dining,
                            color: AppColors.grey,
                            size: 40,
                          );
                        },
                      )
                      : const Icon(
                        Icons.local_dining,
                        color: AppColors.grey,
                        size: 40,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          // Navigasi ke Riwayat menggunakan named route
          Navigator.pushNamed(context, '/Riwayat');
        } else if (index == 2) {
          // Navigasi ke Profile menggunakan named route
          Navigator.pushNamed(context, '/profile');
        }
        // Index 0 (Home) tidak perlu navigasi karena sudah di halaman Home
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}

// Assuming AppColors and AppTextStyles are defined in utils/constants.dart
class AppColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color primary = Colors.green;
  static const Color secondary = Color(0xFF333333);
  static const Color grey = Color(0xFF888888);
  static const Color lightGrey = Color(0xFFDDDDDD);
  static const Color white = Colors.white;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 14,
    color: AppColors.grey,
  );
}