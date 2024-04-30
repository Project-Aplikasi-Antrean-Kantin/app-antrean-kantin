class DetailMenu {
  final int tenantId;
  final int menuId;
  final int harga;
  final String gambar;
  final int id;
  int? isReady;
  String? nama;
  String? deskripsi;

  DetailMenu({
    required this.tenantId,
    required this.menuId,
    required this.harga,
    required this.gambar,
    required this.id,
    this.isReady,
    this.nama,
    this.deskripsi,
  });

  factory DetailMenu.fromJson(Map<String, dynamic> json) => DetailMenu(
        tenantId: json["tenant_id"],
        menuId: json["menu_id"],
        harga: json["harga"],
        gambar: json["gambar"],
        id: json["id"],
        isReady: json["isReady"],
        nama: json["nama"],
        deskripsi: json["deskripsi"],
      );

  Map<String, dynamic> toJson() => {
        "tenant_id": tenantId,
        "menu_id": menuId,
        "harga": harga,
        "gambar": gambar,
        "id": id,
        "isReady": isReady,
      };
}
