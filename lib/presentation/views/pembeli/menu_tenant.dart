import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_cart.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_cashier.dart';
import 'package:testgetdata/presentation/widgets/busy_tenant_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/card_tenant.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/menu_tile.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'cart_page.dart';

class MenuTenant extends StatefulWidget {
  final String url;
  final List<CartMenuModel>? cart;
  final String? cashierTransactionId;
  final bool? fromCashier;
  const MenuTenant(
      {Key? key,
      required this.url,
      this.cart,
      this.cashierTransactionId,
      this.fromCashier = false})
      : super(key: key);

  @override
  _MenuTenantState createState() => _MenuTenantState();
}

class _MenuTenantState extends State<MenuTenant> {
  late Future<TenantModel> _futureTenantFoods;
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  bool isScrolledEnough = false;
  List<TenantFoods>? _filteredFoods;
  TenantModel?
      _currentTenant; // simpan TenantModel supaya tidak perlu dari snapshot terus

  late double expandedHeight;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final now = DateTime.now();
    bool isTenantBusy = false;

    _futureTenantFoods = PublicRemoteDataSource()
        .getTenantFoods(context, widget.url, user.token)
        .then((tenantData) {
      if (tenantData.busyUntil != null) {
        showBusyBottomSheet(context: context, onRetry: () {});
      }

      print("tenantData cak iki slur ${tenantData}");
      print("widget.cart cak iki slur ${widget.cart}");
      if (widget.cart != null) {
        Provider.of<CartProvider>(context, listen: false)
            .setCurrentTenant(tenantData, widget.cart);
      } else {
        Provider.of<CartProvider>(context, listen: false)
            .setCurrentTenant(tenantData, null);
      }
      _currentTenant = tenantData;
      _filteredFoods = tenantData.tenantFoods; // inisialisasi awal
      return tenantData;
    });

    _scrollController.addListener(_scrollListener);
  }

  void _filterFoodsBySearch(String query) {
    if (_currentTenant == null || _currentTenant!.tenantFoods == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredFoods = _currentTenant!.tenantFoods;
      } else {
        _filteredFoods = _currentTenant!.tenantFoods!
            .where(
                (food) => food.nama.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _scrollListener() {
    final scrollOffset = _scrollController.offset;

    if (scrollOffset > expandedHeight - 50 && !isScrolledEnough) {
      setState(() => isScrolledEnough = true);
    } else if (scrollOffset <= expandedHeight - 50 && isScrolledEnough) {
      setState(() => isScrolledEnough = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    expandedHeight = MediaQuery.of(context).size.height / 3.5;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<TenantModel>(
        future: _futureTenantFoods,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
              child: _buildTenantView(context, snapshot.data!, cartProvider),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return ShimmerCard(pageType: 'menuTenant');
        },
      ),

      // ✅ area klik FAB + tombol diperluas
      floatingActionButton: SafeArea(
        child: _buildFloatingActionButton(context, cartProvider)!,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTenantView(
      BuildContext context, TenantModel tenant, CartProvider cartProvider) {
    return WillPopScope(
      onWillPop: () async {
        cartProvider.clearCart(false); // langsung clear
        FocusScope.of(context).unfocus();
        return true;
      },
      child: Stack(children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(tenant),
            const SliverToBoxAdapter(
              child: SizedBox(height: 56),
            ),
            _buildTenantNameSection(tenant.namaTenant),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            (_filteredFoods != null && _filteredFoods!.isEmpty)
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Image(
                              width: MediaQuery.of(context).size.width / 2,
                              image: const AssetImage(
                                  "assets/images/404-Not-Found.png"),
                            ),
                            Text(
                                'Yah menu yang kamu cari masih belum tersedia nih :(',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: AppColors.blackColor400))
                          ],
                        ),
                      ),
                    ),
                  )
                : _buildMenuGrid(tenant, context),
            const SliverToBoxAdapter(
              child: SizedBox(height: 70),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250), // <- durasi animasi
            curve: Curves.easeInOut, // <- smooth curve mirip Tailwind
            padding:
                const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
            color: isScrolledEnough
                ? AppColors.whiteColor100
                : AppColors.whiteColor100.withOpacity(0),

            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: _buildHeader(cartProvider)),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Back
        GestureDetector(
          onTap: () {
            cartProvider.clearCart(false);
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),

        // Search Area
        Flexible(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation, axis: Axis.horizontal, child: child),
            child: _isSearchMode
                ? Container(
                    key: ValueKey('searchField'),
                    margin: EdgeInsets.only(left: 16),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) {
                        _filterFoodsBySearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Cari...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isSearchMode = false;
                              _filteredFoods = _currentTenant!.tenantFoods!;
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    key: ValueKey('searchIcon'),
                    onTap: () {
                      setState(() {
                        _isSearchMode = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(16),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(TenantModel tenant) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      pinned: false,
      expandedHeight: MediaQuery.of(context).size.height / 4.5,
      flexibleSpace: _buildFlexibleSpaceBar(tenant),
    );
  }

  Widget _buildFlexibleSpaceBar(TenantModel tenant) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner background
        Positioned.fill(
          child: FlexibleSpaceBar(
            background: ImageByUrl(
              url: tenant.namaGambar.toString(),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Back button

        // Card menimpa banner bagian bawah
        Positioned(
          bottom: -40, // menimpa keluar banner
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ImageByUrl(
                    url: tenant.namaGambar.toString(),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: _buildTenantInfo(tenant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTenantInfo(TenantModel tenant) {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedTimeSetting03,
              color: tenant.isOnline == true
                  ? tenant.busyUntil != null
                      ? AppColors.warningColor
                      : AppColors.successColor
                  : AppColors.errorColor,
            ),
            const SizedBox(width: 4),
            Text(
              tenant.isOnline == true
                  ? tenant.busyUntil != null
                      ? 'Sibuk'
                      : 'Buka'
                  : 'Tutup',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '|',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${tenant.jamBuka?.substring(0, 5) ?? '09:30'} - ${tenant.jamTutup?.substring(0, 5) ?? '17:00'}',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
          ],
        ),
        Text(
          tenant.namaTenant,
          softWrap: true,
          overflow: TextOverflow.visible,
          maxLines: 4, // boleh lebih dari 1 baris
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingBasket01,
                color: AppColors.secondaryColor),
            const SizedBox(width: 4),
            Text(
              tenant.transaksiBerhasil.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'pesanan berhasil',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
            )
          ],
        ),
        Text(
          'Harga mulai dari ${tenant.range}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  SliverList _buildTenantNameSection(String tenantName) {
    return SliverList(
      delegate: SliverChildListDelegate([
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
      ]),
    );
  }

  SliverGrid _buildMenuGrid(TenantModel tenant, BuildContext context) {
    final isWidthLargerThanHeight =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final List<TenantFoods> foodsToShow =
        _filteredFoods ?? tenant.tenantFoods ?? [];

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return MenuTile(
            tenant: tenant,
            food: foodsToShow[index],
            tenantName: tenant.namaTenant,
            isTenantMenu: true,
            enableNotes: true,
          );
        },
        childCount: foodsToShow.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWidthLargerThanHeight ? 3 : 2,
        childAspectRatio: isWidthLargerThanHeight ? 1 : 0.8,
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, CartProvider cartProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: cartProvider.totalItemCount > 0
          ? SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: FloatingActionButton(
                onPressed: () async {
                  bool isThereUnavailableMenu =
                      await cartProvider.removeUnavailableMenusFromCart(
                          cartProvider.currentTenant!.id.toString(),
                          _currentTenant?.tenantFoods ?? []);
                  final tenantProvider =
                      Provider.of<TenantProvider>(context, listen: false);
                  if (isThereUnavailableMenu) {
                    print(
                        'terdapat menu yang tidak tersedia ${cartProvider.cart}');
                    Fluttertoast.showToast(
                        msg: 'Terdapat menu yang tidak tersedia',
                        backgroundColor: AppColors.errorColor,
                        textColor: Colors.white);
                    isThereUnavailableMenu = false;
                    return;
                  }
                  if (_currentTenant != null &&
                      _currentTenant!.emailPemilik == authProvider.user.email) {
                    showBottomSheetCashier(
                        context,
                        _currentTenant!,
                        (widget.cashierTransactionId != null),
                        widget.cashierTransactionId,
                        widget.fromCashier);
                    return;
                  }
                  if (_currentTenant != null &&
                      _currentTenant!.isOnline == false) {
                    Fluttertoast.showToast(
                        msg: 'Tenant tutup',
                        backgroundColor: AppColors.errorColor,
                        textColor: Colors.white);
                    return;
                  }
                  showBottomSheetCart(context, tenantProvider.tenants!,
                      cartProvider.tenantCarts);
                  // Navigator.push(context, _buildCartPageRoute());
                },
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: _buildCartButtonContent(cartProvider),
              ),
            )
          : null,
    );
  }

  Widget _buildCartButtonContent(CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const HugeIcon(
              icon: HugeIcons.strokeRoundedShoppingCartAdd02,
              color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              FormatCurrency.intToStringCurrency(cartProvider.deliveryCost),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            cartProvider.totalItemCount >= 2
                ? "${cartProvider.totalItemCount} items"
                : "${cartProvider.totalItemCount} item",
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  PageRouteBuilder _buildCartPageRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const CartPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
