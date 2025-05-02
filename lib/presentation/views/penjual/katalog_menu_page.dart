import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/penjual/menu_list_page.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class KatalogMenu extends StatefulWidget {
  const KatalogMenu({Key? key}) : super(key: key);

  @override
  State<KatalogMenu> createState() => _KatalogMenuState();
}

class _KatalogMenuState extends State<KatalogMenu> {
  @override
  void initState() {
    super.initState();
    // final user = context.read<AuthProvider>().user;
    // context.read<KatalogMenuProvider>().fetchData(user.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      context.read<KatalogMenuProvider>().fetchData(user.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider authProvider = Provider.of<AuthProvider>(context);
    // UserModel user = authProvider.user;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          title: Text(
            'Katalog Menu',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_backspace,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Tersedia'),
              Tab(text: 'Habis'),
            ],
          ),
        ),
        body: Consumer<KatalogMenuProvider>(
          builder: (context, provider, child) {
            if (provider.errorMessage != null) {
              return Center(child: Text(provider.errorMessage!));
            }
            return TabBarView(
              children: [
                provider.isLoading
                    ? const ShimmerLoadingWidget(
                        itemCount: 4,
                        itemHeight: 120,
                        showContainer: true,
                        shimmerContainerHome: true,
                      )
                    : MenuListPage(isAvailable: true),
                provider.isLoading
                    ? const ShimmerLoadingWidget(
                        itemCount: 4,
                        itemHeight: 120,
                        showContainer: true,
                        shimmerContainerHome: true,
                      )
                    : MenuListPage(isAvailable: false),
              ],
            );
          },
        ),
      ),
    );
  }
}
