class GetByCategoryController {
  final List dataListMakananTenant;

  GetByCategoryController({required this.dataListMakananTenant});

  List getCategoryMakanan() {
    final makanan = dataListMakananTenant
        .where((element) => element['category'] == 1)
        .toList();
    return makanan;
  }

  List getCategoryMinuman() {
    final minuman = dataListMakananTenant
        .where((element) => element['category'] == 2)
        .toList();
    return minuman;
  }

  Map<String, List<dynamic>> getMenu() {
    Map<String, List<dynamic>> menu = {};

    dataListMakananTenant.forEach((makanan) {
      // menu[makanan['category']] = [makanan];
      // //apakah makanan kategory sudah ada di menu keys
      var isKeyada = menu.keys.contains(makanan['category']);
      if (isKeyada) {
        //jika sudah ada, maka tambahkan ke menu sesuai kategory
        menu[makanan['category']]!.add(makanan);
      } else {
        // jika belum ada, maka tambahkan keys
        menu[makanan['category']] = [makanan];
      }
    });

    return menu;
  }
}
