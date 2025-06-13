import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page.dart';

class RiwayatPageAsRole extends StatefulWidget {
  const RiwayatPageAsRole({Key? key}) : super(key: key);

  @override
  State<RiwayatPageAsRole> createState() => _RiwayatPageAsRoleState();
}

class _RiwayatPageAsRoleState extends State<RiwayatPageAsRole>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabs();
    });
  }

  void _initializeTabs() {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final UserModel user = authProvider.user;

    // Build tabs and tab views dynamically based on permissions
    List<Widget> tabViews = [];
    List<Tab> tabHeaders = [];

    if (user.permission.contains('read order user')) {
      tabViews.add(const RiwayatPage(role: 'user'));
      tabHeaders.add(const Tab(text: 'Beli'));
    }
    if (user.permission.contains('read order tenant')) {
      tabViews.add(const RiwayatPage(role: 'tenant'));
      tabHeaders.add(const Tab(text: 'Jual'));
    }
    if (user.permission.contains('read order masbro')) {
      tabViews.add(const RiwayatPage(role: 'masbro'));
      tabHeaders.add(const Tab(text: 'Antar'));
    }

    if (tabHeaders.isNotEmpty) {
      _tabController = TabController(
        length: tabHeaders.length,
        vsync: this,
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    // Build tabs and tab views dynamically based on permissions
    List<Widget> tabViews = [];
    List<Tab> tabHeaders = [];

    if (user.permission.contains('read order user')) {
      tabViews.add(const RiwayatPage(role: 'user'));
      tabHeaders.add(const Tab(text: 'Beli'));
    }
    if (user.permission.contains('read order tenant')) {
      tabViews.add(const RiwayatPage(role: 'tenant'));
      tabHeaders.add(const Tab(text: 'Jual'));
    }
    if (user.permission.contains('read order masbro')) {
      tabViews.add(const RiwayatPage(role: 'masbro'));
      tabHeaders.add(const Tab(text: 'Antar'));
    }

    return DefaultTabController(
      length: tabViews.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          title: Text(
            'Riwayat',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 18,
              fontWeight: semibold,
            ),
          ),
          centerTitle: true,
          // Tambahkan border hanya jika tabHeaders.length == 1
          // Jika lebih dari 1 tab, tampilkan TabBar
          bottom: tabHeaders.length == 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    height: 1.0,
                    color: AppColors.textColorBlack
                        .withOpacity(0.2), // Warna garis
                  ),
                )
              : tabHeaders.length > 1
                  ? TabBar(
                      controller: _tabController,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      indicatorColor: AppColors.primaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.primaryColor,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: regular,
                      ),
                      tabs: tabHeaders,
                    )
                  : null,
        ),
        body: tabViews.isEmpty
            ? const Center(
                child: Text("Anda tidak memiliki akses ke riwayat."),
              )
            : tabHeaders.length == 1
                ? tabViews[
                    0] // Langsung tampilkan widget tunggal jika hanya 1 tab
                : TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: tabViews,
                  ),
      ),
    );
  }
}
