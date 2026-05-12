import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/widgets/exit_dialog_self_service.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/widgets/fab_menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/widgets/header_menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/menu_tile.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/widgets/sliver_app_bar_menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/busy_tenant_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';

class MenuTenant extends StatefulWidget {
  final String url;
  final List<CartMenuModel>? cart;
  final String? cashierTransactionId;
  final bool? fromCashier;
  final bool? requiredExitCode;
  const MenuTenant(
      {Key? key,
      required this.url,
      this.cart,
      this.cashierTransactionId,
      this.requiredExitCode = false,
      this.fromCashier = false})
      : super(key: key);

  @override
  _MenuTenantState createState() => _MenuTenantState();
}

class _MenuTenantState extends State<MenuTenant> {
  late Future<TenantModel> _futureTenantFoods;
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
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = authProvider.user;

    _futureTenantFoods = PublicRemoteDataSource()
        .getTenantFoods(context, widget.url, user.token)
        .then((tenantData) {
      if (tenantData.busyUntil != null) {
        showBusyBottomSheet(context: context, onRetry: () {});
      }

      if (tenantData.emailPemilik == user.email) {
        cartProvider.setCurrentTenant(tenantData, widget.cart, true);
      } else {
        if (widget.cart != null) {
          cartProvider.setCurrentTenant(tenantData, widget.cart, null);
        } else {
          cartProvider.setCurrentTenant(tenantData, null, null);
        }
      }

      _currentTenant = tenantData;
      _filteredFoods = tenantData.tenantFoods; // inisialisasi awal
      return tenantData;
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
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

    return PopScope(
      canPop: !widget.requiredExitCode!, // ⛔ cegah back langsung
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final result = await showExitDialogSelfService(context);
        if (result == true) {
          cartProvider.popTenant();
          Navigator.of(context).pop(); // ✅ keluar jika kode benar
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: FutureBuilder<TenantModel>(
          future: _futureTenantFoods,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SafeArea(
                child: WillPopScope(
                  onWillPop: () async {
                    if (widget.requiredExitCode == true) {
                      return true;
                    }
                    cartProvider.popTenant();
                    FocusScope.of(context).unfocus();
                    return true;
                  },
                  child: Stack(children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBarMenuTenant(tenant: snapshot.data!),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 56),
                        ),
                        _buildTenantNameSection(snapshot.data!.namaTenant),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 8),
                        ),
                        (_filteredFoods != null && _filteredFoods!.isEmpty)
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Image(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
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
                            : _buildMenuGrid(snapshot.data!, context,
                                cartProvider, authProvider),
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
                        duration: const Duration(
                            milliseconds: 250), // <- durasi animasi
                        curve:
                            Curves.easeInOut, // <- smooth curve mirip Tailwind
                        padding: const EdgeInsets.only(
                            top: 24, left: 16, right: 16, bottom: 16),
                        color: isScrolledEnough
                            ? AppColors.whiteColor100
                            : AppColors.whiteColor100.withOpacity(0),

                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: HeaderMenuTenant(
                                requiredExitCode:
                                    widget.requiredExitCode ?? false,
                                cartProvider: cartProvider,
                                onSearch: _filterFoodsBySearch,
                                onSearchClear: () => _filterFoodsBySearch(''))),
                      ),
                    ),
                  ]),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            return ShimmerCard(pageType: 'menuTenant');
          },
        ),
        floatingActionButton: SafeArea(
          child: FabMenuTenant(
            cashierTransactionId: widget.cashierTransactionId,
            currentTenant: _currentTenant,
            fromCashier: widget.fromCashier,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
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

  SliverGrid _buildMenuGrid(TenantModel tenant, BuildContext context,
      CartProvider cartProvider, AuthProvider authProvider) {
    final isWidthLargerThanHeight =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final List<TenantFoods> foodsToShow =
        _filteredFoods ?? tenant.tenantFoods ?? [];

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final cartItemCount = cartProvider.cart
              .where((item) => item.menuId == foodsToShow[index].id)
              .fold<int>(0, (sum, item) => sum + (item.count));
          return MenuTile(
            isOwner: authProvider.user.email == tenant.emailPemilik,
            cartItemCount: cartItemCount,
            tenant: tenant,
            food: foodsToShow[index],
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
}
