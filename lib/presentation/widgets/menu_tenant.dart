import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_detail_menu.dart';
import 'package:testgetdata/presentation/widgets/sliver_appbar_shadow_delegate.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import '../../core/http/fetch_data_tenant.dart';
import '../../data/model/tenant_foods.dart';
import '../../data/provider/cart_provider.dart';
import '../views/pembeli/cart_page.dart';

class MenuTenant extends StatefulWidget {
  final String url;
  const MenuTenant({Key? key, required this.url}) : super(key: key);

  @override
  _MenuTenantState createState() => _MenuTenantState();
}

class _MenuTenantState extends State<MenuTenant> {
  final List<String> categories = ['All', 'Makanan', 'Minuman', 'Snack'];
  final ScrollController _scrollController = ScrollController();
  late Future<TenantModel> futureTenantFoods;
  Map<String, dynamic> jumlahOffset = {};
  bool isLoading = false;
  TenantModel? foundTenant;
  int? selected;

  @override
  void initState() {
    super.initState();
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    // _scrollController.addListener(_handleScroll);
    futureTenantFoods = fetchTenantFoods(widget.url, user.token);
    //     .then((value) => setState(() => data = value));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _dialogKonfimasiKembali() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Yakin akan keluar?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Item didalam keranjang akan hilang ketika anda keluar.",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        minimumSize:
                            MaterialStateProperty.all(const Size(100, 30)),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color.fromARGB(255, 99, 99, 99),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .clearCart();
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(227, 244, 67, 54),
                        ),
                        minimumSize: MaterialStateProperty.all(Size(100, 30)),
                      ),
                      child: const Text(
                        "Keluar",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<TenantModel>(
        future: futureTenantFoods,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dataTenant = snapshot.data!.namaTenant;
            final List<TenantFoods>? listMenu = snapshot.data!.tenantFoods;

            // ignore: deprecated_member_use
            return WillPopScope(
              onWillPop: () async {
                if (Provider.of<CartProvider>(context, listen: false)
                    .cart
                    .isEmpty) {
                  return true;
                } else {
                  _dialogKonfimasiKembali();
                  return false;
                }
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: AppColors.backgroundColor,
                    scrolledUnderElevation: 0,
                    automaticallyImplyLeading: false,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.width / 2.5,
                    // expandedHeight: 150,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        snapshot.data!.gambar.toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.keyboard_backspace,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        // todo: pindah jadikan widget jika memungkinkan
                        if (Provider.of<CartProvider>(context, listen: false)
                            .cart
                            .isEmpty) {
                          Navigator.of(context).pop();
                        } else {
                          _dialogKonfimasiKembali();
                        }
                      },
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: SliverAppBarShadowDelegate(),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataTenant,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final dataTenant = snapshot.data!.namaKavling;
                        final TenantFoods dataFoods =
                            snapshot.data!.tenantFoods![index];
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // borderRadius: const BorderRadius.all(
                            //   Radius.circular(10),
                            // ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      const Color.fromARGB(255, 200, 200, 200),
                                ),
                                height: 105,
                                width: 105,
                                margin: const EdgeInsets.only(right: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    showDetailMenuBottomSheet(
                                      context,
                                      DetailMenu(
                                        namaTenant: dataTenant,
                                        idMenu: dataFoods.id,
                                        title: dataFoods.nama ?? dataFoods.nama,
                                        gambar: dataFoods.gambar,
                                        description: dataFoods.deskripsi ?? '-',
                                        price: dataFoods.harga,
                                        isReady: dataFoods.isReady,
                                      ),
                                      isCashier: false,
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: dataFoods.gambar != null
                                        ? Image.network(
                                            "${MasbroConstants.baseUrl}${dataFoods.gambar}",
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.photo,
                                                  color: Color.fromARGB(
                                                      255, 120, 120, 120),
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.photo,
                                              color: Color.fromARGB(
                                                  255, 120, 120, 120),
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  height: 100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dataFoods.nama ?? dataFoods.nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.secondaryTextColor,
                                          fontSize: 16,
                                          fontWeight: bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        dataFoods.deskripsi ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryTextColor,
                                          fontSize: 12,
                                          fontWeight: regular,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        FormatCurrency.intToStringCurrency(
                                          dataFoods.harga,
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontWeight: semibold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Consumer<CartProvider>(
                                  builder: (context, data, widget) {
                                    var id = data.cart.indexWhere((element) =>
                                        element.menuId == dataFoods.id);
                                    if (id == -1) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (dataFoods.isReady == 1) {
                                            String name = dataFoods.nama;
                                            String gambar =
                                                dataFoods.gambar ?? 'Kosong';
                                            String tenantName = dataTenant;

                                            print(
                                                "name: $name, gambar: $gambar, tenantName: $tenantName"); // Debug print

                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .addItemToCartOrUpdateQuantity(
                                              dataFoods.id,
                                              name,
                                              dataFoods.harga,
                                              gambar,
                                              tenantName,
                                              dataFoods.deskripsi ?? '-',
                                              true,
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 70),
                                          width: 75,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: dataFoods.isReady == 1
                                                ? AppColors.primaryColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: dataFoods.isReady == 1
                                                  ? AppColors.primaryColor
                                                  : const Color.fromARGB(
                                                      255, 180, 180, 180),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              dataFoods.isReady == 1
                                                  ? 'Tambah'
                                                  : 'Habis',
                                              style: TextStyle(
                                                color: dataFoods.isReady == 1
                                                    ? Colors.white
                                                    : Colors.grey,
                                                fontSize: 12,
                                                fontWeight: semibold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // item sudah ditambahkan ke dalam keranjang belanja
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    Provider.of<CartProvider>(
                                                            context,
                                                            listen: false)
                                                        .addItemToCartOrUpdateQuantity(
                                                            dataFoods.id,
                                                            dataFoods.nama,
                                                            dataFoods.harga,
                                                            dataFoods.nama,
                                                            dataFoods.deskripsi,
                                                            dataTenant,
                                                            false);
                                                  },
                                                  icon: Icon(
                                                    Icons
                                                        .do_not_disturb_on_outlined,
                                                    color:
                                                        AppColors.primaryColor,
                                                    size: 26,
                                                  )),
                                              Consumer<CartProvider>(builder:
                                                  (context, data, widget) {
                                                var id = data.cart.indexWhere(
                                                    (element) =>
                                                        element.menuId ==
                                                        dataFoods.id);
                                                return Text(
                                                  (id == -1)
                                                      ? "0"
                                                      : data.cart[id].count
                                                          .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }),
                                              IconButton(
                                                onPressed: () {
                                                  Provider.of<CartProvider>(
                                                          context,
                                                          listen: false)
                                                      .addItemToCartOrUpdateQuantity(
                                                    dataFoods.id,
                                                    dataFoods.nama,
                                                    dataFoods.harga,
                                                    dataFoods.nama,
                                                    dataFoods.deskripsi,
                                                    dataTenant,
                                                    true,
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.add_circle_outline,
                                                  color: AppColors.primaryColor,
                                                  size: 26,
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              final catatanCart = data.cart
                                                  .where(
                                                    (element) =>
                                                        element.menuId ==
                                                        dataFoods.id,
                                                  )
                                                  .first
                                                  .catatan;
                                              bottomSheetCatatan(context,
                                                      catatanCart ?? '')
                                                  .then(
                                                (value) {
                                                  if (value != null) {
                                                    data.addNote(
                                                        dataFoods.id, value);
                                                  }
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: 75,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.description_outlined,
                                                    size: 12,
                                                  ),
                                                  Text(
                                                    'Catatan',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: snapshot.data!.tenantFoods!.length,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // loader saat get data makanan
          return Container(
            color: AppColors.backgroundColor,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 100,
        ),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: context.watch<CartProvider>().isCartVisible
            ? SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const CartPage();
                      },
                    ));
                  },
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Consumer<CartProvider>(
                    builder: (context, data, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                FormatCurrency.intToStringCurrency(
                                  data.deliveryCost,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              data.totalItemCount >= 2
                                  ? "${data.totalItemCount} items"
                                  : "${data.totalItemCount} item",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
