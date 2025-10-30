import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/penjual/riwayat_kasir_page.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page.dart';

class RiwayatPageAsRole extends StatefulWidget {
  const RiwayatPageAsRole({Key? key}) : super(key: key);

  @override
  State<RiwayatPageAsRole> createState() => _RiwayatPageAsRoleState();
}

class _RiwayatPageAsRoleState extends State<RiwayatPageAsRole>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int selectedActivity = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedActivity);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    List<Widget> tabViews = [];
    List<Tab> tabHeaders = [];

    if (user.permission.contains('read order user')) {
      tabViews.add(const RiwayatPage(tabLabel: 'Beli', role: 'user'));
      tabHeaders.add(const Tab(text: 'Beli'));
    }
    if (user.permission.contains('read order tenant')) {
      tabViews.add(const RiwayatPage(tabLabel: 'Jual', role: 'tenant'));
      tabHeaders.add(const Tab(text: 'Jual'));
    }
    if (user.permission.contains('read order masbro')) {
      tabViews.add(const RiwayatPage(tabLabel: 'Antar', role: 'masbro'));
      tabHeaders.add(const Tab(text: 'Antar'));
    }

    return DefaultTabController(
      length: tabViews.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: user.role.contains('tenant')
              ? AppColors.primaryColor
              : AppColors.backgroundColor,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          toolbarHeight: user.role.contains('tenant') ? 120 : 80,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Aktivitas',
                  style: GoogleFonts.poppins(
                    color: user.role.contains('tenant')
                        ? AppColors.whiteColor
                        : AppColors.primaryColor,
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                ),
              ),
              if (user.role.contains('tenant'))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedActivity = 0);
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selectedActivity == 0
                                    ? AppColors.whiteColor
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  'Online',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: selectedActivity == 0
                                        ? AppColors.primaryColor
                                        : AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedActivity = 1);
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: selectedActivity == 1
                                    ? AppColors.whiteColor
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  'Kasir',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: selectedActivity == 1
                                        ? AppColors.primaryColor
                                        : AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottom: tabHeaders.length > 1 && selectedActivity == 0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: Container(
                    color: AppColors.backgroundColor,
                    child: TabBar(
                      indicatorColor: AppColors.primaryColor,
                      indicatorWeight: 3,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.primaryColor,
                      unselectedLabelColor: Colors.black87,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: regular,
                      ),
                      tabs: tabHeaders,
                    ),
                  ),
                )
              : null,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() => selectedActivity = index);
          },
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: tabViews,
            ),
            const RiwayatKasirPage(),
          ],
        ),
      ),
    );
  }
}
