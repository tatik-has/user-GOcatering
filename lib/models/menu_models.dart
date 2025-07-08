// lib/models/menu_models.dart
class Menu {
  final String id;
  final String nama;
  final String deskripsi;
  final String harga;
  final String? gambar;
  final String kategoriUtama;
  final String rating;

  Menu({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    this.gambar,
    required this.kategoriUtama,
    required this.rating,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['name']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? '',
      harga: json['harga']?.toString() ?? json['price']?.toString() ?? 'Rp 0',
      gambar: json['gambar']?.toString() ?? json['image']?.toString(),
      kategoriUtama: json['kategori_utama']?.toString() ?? json['category']?.toString() ?? 'unknown',
      rating: json['rating']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'kategori_utama': kategoriUtama,
      'rating': rating,
    };
  }
}

class Kuliner {
  final String id;
  final String nama;
  final String deskripsi;
  final String harga;
  final String? gambar;
  final String rating;

  Kuliner({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    this.gambar,
    required this.rating,
  });

  factory Kuliner.fromJson(Map<String, dynamic> json) {
    return Kuliner(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['name']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? '',
      harga: json['harga']?.toString() ?? json['price']?.toString() ?? 'Rp 0',
      gambar: json['gambar']?.toString() ?? json['image']?.toString(),
      rating: json['rating']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'rating': rating,
    };
  }
}

class PaketBulanan {
  final String id;
  final String nama;
  final String deskripsi;
  final String harga;
  final String? gambar;
  final String rating;

  PaketBulanan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    this.gambar,
    required this.rating,
  });

  factory PaketBulanan.fromJson(Map<String, dynamic> json) {
    return PaketBulanan(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['name']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? '',
      harga: json['harga']?.toString() ?? json['price']?.toString() ?? 'Rp 0',
      gambar: json['gambar']?.toString() ?? json['image']?.toString(),
      rating: json['rating']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'rating': rating,
    };
  }
}

class Katering {
  final String id;
  final String nama;
  final String deskripsi;
  final String harga;
  final String? gambar;
  final String rating;

  Katering({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    this.gambar,
    required this.rating,
  });

  factory Katering.fromJson(Map<String, dynamic> json) {
    return Katering(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? json['name']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? json['description']?.toString() ?? '',
      harga: json['harga']?.toString() ?? json['price']?.toString() ?? 'Rp 0',
      gambar: json['gambar']?.toString() ?? json['image']?.toString(),
      rating: json['rating']?.toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'rating': rating,
    };
  }
}