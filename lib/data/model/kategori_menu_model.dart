class KategoriMenu {
  final int id;
  final String nama;
  final int kategoriId;

  KategoriMenu({
    required this.id,
    required this.nama,
    required this.kategoriId,
  });

  factory KategoriMenu.fromJson(Map<String, dynamic> json) => KategoriMenu(
        id: json["id"],
        nama: json["nama"],
        kategoriId: json["kategori_id"],
      );
}
