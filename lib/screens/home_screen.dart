import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_catring/screens/katering_screen.dart'
    show KateringDetailScreen;
import 'package:go_catring/screens/katering_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_models.dart';
import '../services/product_service.dart';
import '../utils/constants.dart';
import 'kuliner_screen.dart';
import '../screens/paket_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String namaUser = '';
  String keyword = '';
  List<Menu> allMenuItems = [];
  List<Kuliner> listKuliner = [];
  List<PaketBulanan> listPaketBulanan = [];
  List<Katering> listKatering = [];

  bool isLoadingAllMenu = true;
  String? errorMessageAllMenu;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadAllMenuData();
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

  Future<void> loadAllMenuData() async {
    setState(() {
      isLoadingAllMenu = true;
      errorMessageAllMenu = null;
    });

    final result = await ProductService.getMenu();

    setState(() {
      isLoadingAllMenu = false;
      if (result['success']) {
        allMenuItems = result['data'] as List<Menu>;
        _filterMenuItems();
      } else {
        errorMessageAllMenu = result['message'];
        allMenuItems = [];
        listKuliner = [];
        listPaketBulanan = [];
        listKatering = [];
      }
    });
  }

  void _filterMenuItems() {
    listKuliner =
        allMenuItems
            .where((menu) => menu.kategoriUtama == 'kuliner')
            .map((menu) => Kuliner.fromJson(menu.toJson()))
            .toList();
    listPaketBulanan =
        allMenuItems
            .where((menu) => menu.kategoriUtama == 'paket_bulanan')
            .map((menu) => PaketBulanan.fromJson(menu.toJson()))
            .toList();
    listKatering =
        allMenuItems
            .where((menu) => menu.kategoriUtama == 'katering')
            .map((menu) => Katering.fromJson(menu.toJson()))
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
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 24),
                if (isLoadingAllMenu)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessageAllMenu != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Error: ${errorMessageAllMenu ?? 'Terjadi kesalahan'}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
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

  // Berikut adalah builder untuk UI

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color.fromARGB(255, 238, 241, 238),
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
              const Text(
                'Temukan Seleramu,',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(94, 143, 45, 1), // hijau custom
                ),
              ),
              const Text(
                'Gelar Piringmu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E8F2D), // hijau custom
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(94, 143, 45, 1),
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
              onChanged: (value) => setState(() => keyword = value),
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

  // Tambahkan builder konten kuliner, paket bulanan, katering
  Widget _buildKulinerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kuliner', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: listKuliner.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final kuliner = listKuliner[index];
              return GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KulinerScreen(kuliner: kuliner),
                      ),
                    ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(94, 143, 45, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            (kuliner.gambar?.isNotEmpty ?? false)
                                ? Image.network(
                                  '${AppConstants.imageUrl}/storage/${kuliner.gambar}',
                                  fit: BoxFit.cover,
                                )
                                : const Icon(
                                  Icons.restaurant,
                                  color: Color.fromARGB(255, 229, 233, 227),
                                  size: 30,
                                ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      kuliner.nama,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

 Widget _buildPaketBulananSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Paket Bulanan', style: AppTextStyles.heading),
      const SizedBox(height: 4),
      const Text(
        'Menu terlaris di sekitarmu',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 200, // Dikurangi dari 250 menjadi 200
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: listPaketBulanan.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final paket = listPaketBulanan[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaketDetailScreen(menuId: paket.id.toString()),
                  ),
                );
              },
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: (paket.gambar?.isNotEmpty ?? false)
                          ? Image.network(
                              '${AppConstants.imageUrl}/storage/${paket.gambar}',
                              width: double.infinity,
                              height: 100, // Dikurangi dari 120 menjadi 100
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.fastfood,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    // Info section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10), // Dikurangi dari 12 menjadi 10
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Nama paket - dibuat bold dan ukuran font disesuaikan
                            Text(
                              paket.nama,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, // Dibuat bold
                                fontSize: 16, // Dikurangi dari 18 menjadi 16
                                color: Color(0xFF333333),
                              ),
                            ),
                            // Bottom section dengan button dan rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Button Pesan
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, // Dikurangi dari 14
                                    vertical: 5, // Dikurangi dari 6
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(94, 143, 45, 1),
                                    borderRadius: BorderRadius.circular(14), // Dikurangi dari 16
                                  ),
                                  child: const Text(
                                    'Pesan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11, // Dikurangi dari 12
                                      fontWeight: FontWeight.w600, // Dibuat sedikit lebih bold
                                    ),
                                  ),
                                ),
                                // Rating
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3), // Dikurangi dari 4
                                    Text(
                                      paket.rating,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
  Widget _buildKateringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Katering', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        const Text(
          'Temukan selera makananmu',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Column(
          children:
              listKatering.map((katering) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => KateringDetailScreen(
                              id: int.parse(katering.id.toString()),
                            ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar dengan overlay
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child:
                                  (katering.gambar?.isNotEmpty ?? false)
                                      ? Image.network(
                                        '${AppConstants.imageUrl}/storage/${katering.gambar}',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.local_dining,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),
                            // Tombol love di kanan atas
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(94, 143, 45, 1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Color.fromARGB(255, 254, 255, 255),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Info section
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Nama, harga, dan rating
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      katering.nama,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      katering.harga,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          katering.rating,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol pesan
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(94, 143, 45, 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Pesan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromRGBO(94, 143, 45, 1),
      unselectedItemColor: AppColors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/Riwayat');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/profile');
        }
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
