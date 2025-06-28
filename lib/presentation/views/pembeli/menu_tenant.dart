import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/menu_tile.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'cart_page.dart';

class MenuTenant extends StatefulWidget {
  final String url;

  const MenuTenant({Key? key, required this.url}) : super(key: key);

  @override
  _MenuTenantState createState() => _MenuTenantState();
}

class _MenuTenantState extends State<MenuTenant> {
  late Future<TenantModel> _futureTenantFoods;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _futureTenantFoods = PublicRemoteDataSource()
        .getTenantFoods(context, widget.url, user.token);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<TenantModel>(
        future: _futureTenantFoods,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildTenantView(context, snapshot.data!, cartProvider);
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return ShimmerCard(pageType: 'menuTenant');
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context, cartProvider),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTenantView(
      BuildContext context, TenantModel tenant, CartProvider cartProvider) {
    return WillPopScope(
      onWillPop: () async {
        if (cartProvider.cart.isEmpty) {
          FocusScope.of(context).unfocus();
          return true;
        }
        await _showExitConfirmationDialog(context, cartProvider);
        FocusScope.of(context).unfocus();
        return false;
      },
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(tenant),
          _buildTenantNameSection(tenant.namaTenant),
          _buildMenuList(tenant),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 70,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(TenantModel tenant) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: MediaQuery.of(context).size.height / 4.5,
      flexibleSpace: _buildFlexibleSpaceBar(tenant),
    );
  }

  Widget _buildFlexibleSpaceBar(TenantModel tenant) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isCollapsed = constraints.biggest.height <=
            kToolbarHeight + MediaQuery.of(context).padding.top;

        return Stack(
          children: [
            FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 19, left: 70),
              expandedTitleScale: 1.2,
              title: isCollapsed
                  ? Text(
                      tenant.namaTenant,
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 18,
                        fontWeight: semibold,
                      ),
                    )
                  : null,
              background: Image.network(
                tenant.gambar.toString(),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  final cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  if (cartProvider.cart.isEmpty) {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                  } else {
                    _showExitConfirmationDialog(context, cartProvider);
                  }
                },
                child: Container(
                  decoration: isCollapsed
                      ? null
                      : BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_sharp,
                    color: isCollapsed ? Colors.black : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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

  SliverList _buildMenuList(TenantModel tenant) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                child: MenuTile(
                  food: tenant.tenantFoods![index],
                  tenantName: tenant.namaTenant,
                  isTenantMenu: true,
                  enableNotes: true,
                ),
              ),
              if (index < tenant.tenantFoods!.length - 1)
                Divider(
                  color: Colors.grey,
                  thickness: 0.2,
                  height: 1,
                  indent: 15,
                  endIndent: 15,
                ),
            ],
          );
        },
        childCount: tenant.tenantFoods!.length,
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, CartProvider cartProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: cartProvider.totalItemCount > 0
          ? SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: FloatingActionButton(
                onPressed: () {
                  KasirProvider kasirProvider =
                      Provider.of<KasirProvider>(context, listen: false);
                  kasirProvider.setIsKasir(false);
                  log("Is Kasir: ${kasirProvider.isKasir}");
                  Navigator.push(context, _buildCartPageRoute());
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.shopping_cart, color: Colors.white),
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

  Future<void> _showExitConfirmationDialog(
      BuildContext context, CartProvider cartProvider) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Yakin akan keluar?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Item didalam keranjang akan hilang ketika anda keluar.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all(const Size(100, 30)),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      cartProvider.clearCart();
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                      cartProvider.roomId == null;
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.primaryColor),
                      minimumSize: WidgetStateProperty.all(const Size(100, 30)),
                    ),
                    child: const Text(
                      "Keluar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
