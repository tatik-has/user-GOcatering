class Katering {
  final int id;
  final String nama;
  final String deskripsi;
  final String gambar;
  final double rating;
  final bool isAktif;
  final int harga;

  Katering({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.gambar,
    required this.rating,
    required this.isAktif,
    required this.harga,
  });

  factory Katering.fromJson(Map<String, dynamic> json) {
    return Katering(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nama: json['name'] ?? '',
      deskripsi: json['description'] ?? '',
      gambar: (json['images'] != null &&
              json['images'] is List &&
              json['images'].isNotEmpty)
          ? json['images'][0]
          : '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : double.tryParse(json['rating'].toString()) ?? 0.0,
      harga: json['price'] is int
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,
      isAktif: true,
    );
  }
}
