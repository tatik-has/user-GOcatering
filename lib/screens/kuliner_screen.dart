// kuliner_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/menu_models.dart';
import '../utils/constants.dart';

class KulinerScreen extends StatefulWidget {
  final Kuliner kuliner;

  const KulinerScreen({Key? key, required this.kuliner}) : super(key: key);

  @override
  State<KulinerScreen> createState() => _KulinerScreenState();
}

class _KulinerScreenState extends State<KulinerScreen> {
  int quantity = 1;
  bool isOrdering = false;
  bool isLoadingMenus = true;
  List<OrderItem> selectedItems = [];
  List<Kuliner> additionalMenus = [];

  @override
  void initState() {
    super.initState();
    // Add main item as first selected item
    selectedItems.add(OrderItem(
      kuliner: widget.kuliner,
      quantity: quantity,
    ));
    _loadAdditionalMenus();
  }

  Future<void> _loadAdditionalMenus() async {
    try {
      setState(() {
        isLoadingMenus = true;
      });

      // Call your API to fetch menus
      await _fetchMenusFromAPI();
      
      setState(() {
        isLoadingMenus = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMenus = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat menu tambahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // TODO: Implement this method to call your API
  Future<List<Kuliner>> _fetchMenusFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/menu'), // Adjust endpoint as needed
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Adjust based on your API response structure
        List<Kuliner> menus = (data['data'] as List)
            .map((item) => Kuliner.fromJson(item))
            .where((menu) => menu.id != widget.kuliner.id) // Exclude current item
            .toList();
        
        setState(() {
          additionalMenus = menus;
        });
        
        return menus;
      } else {
        throw Exception('Failed to load menus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kuliner',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Item Section
              _buildMainItemSection(),
              
              const SizedBox(height: 30),
              
              // Additional Menu Section
              _buildAdditionalMenuSection(),
              
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      
      // Bottom Order Button
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildMainItemSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Main Item Card
      _buildMenuCard(widget.kuliner, quantity, isMainItem: true),

      const SizedBox(height: 16),

      // Quantity Selector
      _buildQuantitySelector(),

      const SizedBox(height: 16),

      // Tampilkan tambahan menu dengan style kartu besar
      if (selectedItems.length > 1) ...[
        const Text(
          'Menu Tambahan:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Column(
          children: selectedItems
              .where((item) => item.kuliner.id != widget.kuliner.id)
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMenuCard(item.kuliner, item.quantity),
                  ))
              .toList(),
        ),
      ],
    ],
  );
}

Widget _buildMenuCard(Kuliner kuliner, int qty, {bool isMainItem = false}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Gambar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: kuliner.gambar?.isNotEmpty ?? false
                ? Image.network(
                    '${AppConstants.imageUrl}/storage/${kuliner.gambar}',
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.restaurant, size: 40, color: Colors.grey),
          ),
        ),

        const SizedBox(width: 16),

        // Konten
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kuliner.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kuliner.deskripsi.isNotEmpty
                    ? kuliner.deskripsi
                    : 'Sesuaikan harga dengan budget yang tersedia',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                kuliner.harga,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        if (!isMainItem) ...[
          const SizedBox(width: 12),
          Text('x$qty', style: const TextStyle(fontSize: 14)),
        ],
      ],
    ),
  );
}


  Widget _buildAdditionalMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambah menu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Additional Menu Grid
        _buildAdditionalMenuGrid(),
      ],
    );
  }

  Widget _buildAdditionalMenuGrid() {
    if (isLoadingMenus) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (additionalMenus.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          'Tidak ada menu tambahan tersedia',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: additionalMenus.length,
      itemBuilder: (context, index) {
        final menu = additionalMenus[index];
        final isSelected = selectedItems.any((item) => item.kuliner.id == menu.id);
        
        return GestureDetector(
          onTap: () => _toggleAdditionalMenu(menu),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _buildMenuImage(menu),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                menu.nama,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    if (widget.kuliner.gambar?.isNotEmpty ?? false) {
      return Image.network(
        '${AppConstants.imageUrl}/storage/${widget.kuliner.gambar}',
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildMenuImage(Kuliner menu) {
    if (menu.gambar?.isNotEmpty ?? false) {
      return Image.network(
        '${AppConstants.imageUrl}/storage/${menu.gambar}',
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.restaurant,
              size: 24,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Icon(
          Icons.restaurant,
          size: 24,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(
        Icons.restaurant,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Harga',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: quantity > 1 ? () {
                  setState(() {
                    quantity--;
                    // Update main item quantity
                    selectedItems[0].quantity = quantity;
                  });
                } : null,
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: quantity > 1 ? Colors.orange : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: quantity < 99 ? () {
                  setState(() {
                    quantity++;
                    // Update main item quantity
                    selectedItems[0].quantity = quantity;
                  });
                } : null,
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: quantity < 99 ? Colors.orange : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    int totalItems = selectedItems.fold(0, (sum, item) => sum + item.quantity);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isOrdering ? null : _orderNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isOrdering 
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Pesan ($totalItems)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _toggleAdditionalMenu(Kuliner menu) {
    setState(() {
      final existingIndex = selectedItems.indexWhere((item) => item.kuliner.id == menu.id);
      
      if (existingIndex != -1) {
        // Remove if already selected
        selectedItems.removeAt(existingIndex);
      } else {
        // Add new item
        selectedItems.add(OrderItem(
          kuliner: menu,
          quantity: 1,
        ));
      }
    });
  }

  Future<void> _orderNow() async {
  setState(() {
    isOrdering = true;
  });

  try {
    // Hitung total_amount dengan mengonversi harga menjadi double
    final totalAmount = selectedItems.fold(0.0, (sum, item) {
      // Mengonversi harga menjadi double jika perlu
      final price = double.tryParse(item.kuliner.harga) ?? 0.0; // Ganti dengan 0.0 jika konversi gagal
      return sum + (price * item.quantity);
    });

    // Siapkan data untuk dikirim
    final orderData = {
      'customer_name': 'John Doe', // Ganti dengan nama pelanggan
      'customer_phone': '1234567890', // Ganti dengan nomor telepon pelanggan
      'items': selectedItems.map((item) {
        return {
          'menu_id': item.kuliner.id,
          'menu_name': item.kuliner.nama,
          'quantity': item.quantity,
          'price': item.kuliner.harga, // Pastikan harga dalam format yang benar
        };
      }).toList(),
      'total_amount': totalAmount, // Gunakan totalAmount yang sudah dihitung
      'delivery_address': 'Jl. Contoh No. 123', // Ganti dengan alamat pengiriman
    };

    // Kirim data ke API
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/pemesanan'), // Ganti dengan endpoint yang sesuai
      headers: {
        'Content-Type': 'application/json',
        // Tambahkan authorization header jika diperlukan
        // 'Authorization': 'Bearer $token',
      },
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      // Tampilkan dialog sukses
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pesanan Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pesanan Anda telah berhasil dibuat:'),
              const SizedBox(height: 8),
              ...selectedItems.map((item) => Text(
                '• ${item.kuliner.nama} x${item.quantity}',
                style: const TextStyle(fontSize: 14),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close kuliner screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Gagal membuat pesanan: ${response.body}');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        isOrdering = false;
      });
    }
  }
}
}

// Helper class for order items
class OrderItem {
  final Kuliner kuliner;
  int quantity;

  OrderItem({required this.kuliner, required this.quantity});
}