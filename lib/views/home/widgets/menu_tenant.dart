import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/home/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/views/home/widgets/bottom_sheet_detail_menu.dart';
import 'package:testgetdata/views/home/widgets/search_menu.dart';
import 'package:testgetdata/views/theme.dart';
import '../../../http/fetch_data_tenant.dart';
import '../../../model/tenant_foods.dart';
import '../../../provider/cart_provider.dart';
import '../pages/keranjang/cart_page.dart';

class MenuTenant extends StatefulWidget {
  final String url;
  const MenuTenant({Key? key, required this.url}) : super(key: key);

  @override
  _MenuTenantState createState() => _MenuTenantState();
}

class _MenuTenantState extends State<MenuTenant> {
  final List<String> categories = ['All', 'Makanan', 'Minuman', 'Snack'];
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarTransparent = true;
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
    _scrollController.addListener(_handleScroll);
    futureTenantFoods = fetchTenantFoods(widget.url, user.token);
    //     .then((value) => setState(() => data = value));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset >= 200) {
      setState(() {
        _isAppBarTransparent = false;
      });
    } else {
      setState(() {
        _isAppBarTransparent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: FutureBuilder<TenantModel>(
        future: futureTenantFoods,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dataTenant = snapshot.data!.namaTenant;
            final List<TenantFoods>? listMenu = snapshot.data!.tenantFoods;

            return WillPopScope(
              // todo: pindah jadikan widget jika memungkinkan
              onWillPop: () async {
                if (Provider.of<CartProvider>(context, listen: false)
                    .cart
                    .isEmpty) {
                  return true;
                } else {
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
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          side: const BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all(
                                          Size(100, 30)),
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
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .clearCart();
                                      Navigator.of(context).pop();
                                      Navigator.pop(
                                          context); // Kembali ke halaman sebelumnya
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Color.fromARGB(227, 244, 67, 54),
                                      ),
                                      minimumSize: MaterialStateProperty.all(
                                          Size(100, 30)),
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
                  // return cek ga langsung balik ndek halaman awal
                  return false;
                }
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    scrolledUnderElevation: 0,
                    automaticallyImplyLeading: false,
                    pinned: true,
                    expandedHeight: 200,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: const BorderSide(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              minimumSize:
                                                  MaterialStateProperty.all(
                                                      Size(100, 30)),
                                            ),
                                            child: const Text(
                                              "Batal",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 99, 99, 99),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          TextButton(
                                            onPressed: () {
                                              Provider.of<CartProvider>(context,
                                                      listen: false)
                                                  .clearCart();
                                              Navigator.of(context).pop();
                                              Navigator.pop(
                                                  context); // Kembali ke halaman sebelumnya
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Color.fromARGB(
                                                    227, 244, 67, 54),
                                              ),
                                              minimumSize:
                                                  MaterialStateProperty.all(
                                                      Size(100, 30)),
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
                      },
                    ),
                    // actions: [
                    //   IconButton(
                    //     icon: const Icon(
                    //       Icons.search,
                    //       color: Colors.black,
                    //       size: 24,
                    //     ),
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => SearchPageMenu(
                    //             data: [],
                    //             // url: MasbroConstants.url,
                    //             url: MasbroConstants.url,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ],
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
                          margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey, // Warna border
                                width: 1.0, // Lebar border
                              ),
                              top: BorderSide(
                                color: Colors.grey, // Warna border
                                width: 0.2, // Lebar border
                              ),
                              left: BorderSide(
                                color: Colors.grey, // Warna border
                                width: 0.2, // Lebar border
                              ),
                              right: BorderSide(
                                color: Colors.grey, // Warna border
                                width: 0.2, // Lebar border
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color.fromARGB(
                                        255, 200, 200, 200),
                                  ),
                                  height: 100,
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDetailMenuBottomSheet(
                                          context,
                                          DetailMenu(
                                            namaTenant: dataTenant,
                                            idMenu: dataFoods.id,
                                            title: dataFoods.nama ??
                                                dataFoods.nama,
                                            gambar: dataFoods.gambar,
                                            description:
                                                dataFoods.deskripsi ?? '-',
                                            price: dataFoods.harga,
                                            isReady: dataFoods.isReady,
                                          ),
                                          isCashier: false);
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: primaryColor,
                                          ),
                                        ),
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                            dataFoods.harga,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          dataFoods.deskripsi ?? '-',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
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
                                                  .addRemove(
                                                dataFoods.id,
                                                name,
                                                dataFoods.harga,
                                                gambar,
                                                tenantName,
                                                dataFoods.deskripsi,
                                                true,
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 75,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: dataFoods.isReady == 1
                                                  ? Colors.transparent
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: dataFoods.isReady == 1
                                                    ? primaryColor
                                                    : const Color.fromARGB(
                                                        255, 180, 180, 180),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  dataFoods.isReady == 1
                                                      ? 'Tambah'
                                                      : 'Habis',
                                                  style: TextStyle(
                                                    color:
                                                        dataFoods.isReady == 1
                                                            ? primaryColor
                                                            : Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        // item sudah ditambahkan ke dalam keranjang belanja
                                        return Container(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        Provider.of<CartProvider>(
                                                                context,
                                                                listen: false)
                                                            .addRemove(
                                                                dataFoods.id,
                                                                dataFoods.nama,
                                                                dataFoods.harga,
                                                                dataFoods.nama,
                                                                dataFoods
                                                                    .deskripsi,
                                                                dataTenant,
                                                                false);
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .do_not_disturb_on_outlined,
                                                        color: primaryColor,
                                                        size: 26,
                                                      )),
                                                  Consumer<CartProvider>(
                                                      builder: (context, data,
                                                          widget) {
                                                    var id = data.cart
                                                        .indexWhere((element) =>
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
                                                          .addRemove(
                                                              dataFoods.id,
                                                              dataFoods.nama,
                                                              dataFoods.harga,
                                                              dataFoods.nama,
                                                              dataFoods
                                                                  .deskripsi,
                                                              dataTenant,
                                                              true);
                                                    },
                                                    icon: Icon(
                                                      Icons.add_circle_outline,
                                                      color: primaryColor,
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
                                                        data.tambahCatatan(
                                                            dataFoods.id,
                                                            value);
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
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .description_outlined,
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
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: Duration(
          milliseconds: 100,
        ),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: context.watch<CartProvider>().isCartShow
            ? SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const Cart();
                      },
                    ));
                  },
                  backgroundColor: primaryColor,
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
                                  data.cost,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              data.total >= 2
                                  ? "${data.total} items"
                                  : "${data.total} item",
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
