import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_detail_menu.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';
import 'package:testgetdata/presentation/widgets/sliver_appbar_shadow_delegate.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import '../../../data/remote/fetch_data_tenant.dart';
import '../../../data/model/tenant_foods.dart';
import '../../provider/cart_provider.dart';
import 'cart_page.dart';

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

  Route CartPageUser() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const CartPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

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
          backgroundColor: AppColors.backgroundColor,
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
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        minimumSize:
                            WidgetStateProperty.all(const Size(100, 30)),
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
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.primaryColor,
                        ),
                        minimumSize: WidgetStateProperty.all(Size(100, 30)),
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
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<TenantModel>(
        future: futureTenantFoods,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tenantName = snapshot.data!.namaTenant;

            // ignore: deprecated_member_use
            return WillPopScope(
              onWillPop: () async {
                if (cartProvider.cart.isEmpty) {
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
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isCollapsed = constraints.biggest.height <=
                            kToolbarHeight + MediaQuery.of(context).padding.top;

                        return Stack(
                          children: [
                            FlexibleSpaceBar(
                              titlePadding:
                                  const EdgeInsets.only(bottom: 19, left: 70),
                              expandedTitleScale: 1.2,
                              title: isCollapsed
                                  ? Text(
                                      tenantName,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColorBlack,
                                        fontSize: 18,
                                        fontWeight: semibold,
                                      ),
                                    )
                                  : null,
                              background: Image.network(
                                snapshot.data!.gambar.toString(),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).padding.top +
                                  8, // Posisi agar tidak tertutup status bar
                              left: 16, // Posisi kiri
                              child: GestureDetector(
                                onTap: () {
                                  if (cartProvider.cart.isEmpty) {
                                    Navigator.of(context).pop();
                                  } else {
                                    _dialogKonfimasiKembali();
                                  }
                                },
                                child: Container(
                                  decoration: isCollapsed
                                      ? null // Hilangkan background saat collapsed
                                      : BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.arrow_back_sharp,
                                    color: isCollapsed
                                        ? Colors.black
                                        : Colors.white, // Ganti warna ikon
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                            // Todo: Search Menu Makanan
                            // Positioned(
                            //   top: MediaQuery.of(context).padding.top +
                            //       8, // Posisi agar tidak tertutup status bar
                            //   right: 16, // Posisi kiri
                            //   child: GestureDetector(
                            //     onTap: () {},
                            //     child: Container(
                            //       decoration: isCollapsed
                            //           ? null // Hilangkan background saat collapsed
                            //           : BoxDecoration(
                            //               color: Colors.black.withOpacity(0.3),
                            //               shape: BoxShape.circle,
                            //             ),
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: Icon(
                            //         Icons.search,
                            //         color: isCollapsed
                            //             ? Colors.black
                            //             : Colors.white, // Ganti warna ikon
                            //         size: 20,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Container nama tenant
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Text(
                            tenantName,
                            style: GoogleFonts.poppins(
                              fontWeight: semibold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Container menu makanan tenant
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        bool _isLoading = true;
                        final TenantFoods dataFoods =
                            snapshot.data!.tenantFoods![index];
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 0.3,
                                color:
                                    AppColors.lineColorBlack.withOpacity(0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Container gambar
                              Container(
                                height: 105,
                                width: 105,
                                margin: const EdgeInsets.only(right: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    showDetailMenuBottomSheet(
                                      context,
                                      DetailMenu(
                                        namaTenant: tenantName,
                                        dataFoods: dataFoods,
                                      ),
                                      isCashier: false,
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      children: [
                                        // Shimmer effect sebagai placeholder
                                        Positioned.fill(
                                          child: Visibility(
                                            visible: _isLoading,
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Gambar dengan loadingBuilder
                                        Image.network(
                                          "${MasbroConstants.baseUrl}${dataFoods.gambar}",
                                          fit: BoxFit.cover,
                                          width: 105,
                                          height: 105,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              // Gambar telah dimuat
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                if (mounted) {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                }
                                              });
                                              return child;
                                            }
                                            return Container(); // Kosong karena shimmer sudah menangani loading
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ],
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
                                          color: AppColors.textColorBlack,
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
                                          color: AppColors.textColorBlack,
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
                                            String gambar =
                                                dataFoods.gambar ?? 'Kosong';

                                            log("name: ${dataFoods.nama}, gambar: $gambar, tenantName: $tenantName");

                                            cartProvider
                                                .addItemToCartOrUpdateQuantity(
                                              dataFoods.id,
                                              dataFoods.nama,
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
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: dataFoods.isReady == 1
                                                ? AppColors.primaryColor
                                                : AppColors.backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: dataFoods.isReady == 1
                                                  ? AppColors.primaryColor
                                                  : AppColors.textColorwhite,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              dataFoods.isReady == 1
                                                  ? 'Tambah'
                                                  : 'Habis',
                                              style: GoogleFonts.poppins(
                                                color: dataFoods.isReady == 1
                                                    ? AppColors.textColorwhite
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
                                                    cartProvider
                                                        .addItemToCartOrUpdateQuantity(
                                                      dataFoods.id,
                                                      dataFoods.nama,
                                                      dataFoods.harga,
                                                      dataFoods.nama,
                                                      dataFoods.deskripsi ??
                                                          '-',
                                                      tenantName,
                                                      false,
                                                    );
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
                                                  cartProvider
                                                      .addItemToCartOrUpdateQuantity(
                                                    dataFoods.id,
                                                    dataFoods.nama,
                                                    dataFoods.harga,
                                                    dataFoods.nama,
                                                    dataFoods.deskripsi ?? "-",
                                                    tenantName,
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
          return ShimmerLoadingWidget(
            shimmerContainerHome: true,
            itemCount: 3,
            borderRadiusList: BorderRadius.circular(0),
            padding: EdgeInsets.all(0),
            marginContainer: EdgeInsets.only(bottom: 13),
            borderRadiusContainer: BorderRadius.circular(0),
            showContainer: true,
            containerHeight: 205,
            itemHeight: 140,
            showContainerTitle: true,
            containerTittleHeight: 35,
            marginContainerTitle:
                EdgeInsets.only(left: 15, right: 60, bottom: 11),
            borderRadiusContainerTitle: BorderRadius.circular(0),
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
                    Navigator.push(context, CartPageUser());
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
