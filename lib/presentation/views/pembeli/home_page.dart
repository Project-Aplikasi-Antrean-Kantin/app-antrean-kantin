import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/core/http/fetch_all_tenant.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/data/provider/coin_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/carousel_widget.dart';
import 'package:testgetdata/presentation/widgets/list_tenant.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TenantModel>> futureTenant;
  final String url = "${MasbroConstants.url}/tenants";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];
  bool isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    futureTenant = fetchTenant(url, user.token);
    context.read<CoinProvider>().fetchData(user.token);
  }

  void filterTenants(String value) {
    setState(() {
      foundTenant = value.isEmpty
          ? fullTenant
          : fullTenant.where((tenant) {
              final searchString = "${tenant.namaTenant} ${tenant.namaKavling} "
                      "${tenant.tenantFoods!.map((food) => food.nama).join(' ')}"
                  .toLowerCase();
              return searchString.contains(value.toLowerCase());
            }).toList();
    });
  }

  void showErrorBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 72, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Tidak ada koneksi internet',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const NavbarHome(pageIndex: 0)),
                (route) => route.isFirst,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Route topUpPgae(coin, email) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TopupPage(
        coin: coin,
        email: email,
      ),
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (!user.permission.contains('read beranda')) {
      return const Center(child: Text('TIDAK ADA AKSES WOY'));
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            _buildTenantList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return SizedBox(
      height: 265,
      child: Stack(
        children: [
          // CarouselWidget(),
          Image.asset(
            'assets/images/iklan 1.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 15,
            right: 15,
            child: SearchWidget(
              paddingHorizontal: 0,
              paddingVertical: 0,
              formHeight: 43,
              tittle: "Cari menu kesukaanmu . . .",
              onChanged: filterTenants,
            ),
          ),
          Positioned(
            top: 195,
            left: 15,
            right: 15,
            child: _buildCoinSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final int saldoCoin = context.watch<CoinProvider>().saldoKoin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.containerColorWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.2, color: AppColors.containerColorGrey),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.toll, size: 30, color: Colors.yellow[700]),
              const SizedBox(width: 7),
              Text(
                '$saldoCoin',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorBlack,
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            elevation: 0,
            color: AppColors.backgroundColor,
            borderColor: AppColors.primaryColor,
            width: 20,
            onPressed: () {
              Navigator.push(context, topUpPgae(saldoCoin, user.email));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_box,
                  size: 24,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  'Top Up',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantList() {
    return FutureBuilder<List<TenantModel>>(
      // future: futureTenant,
      future:
          Future.delayed(const Duration(milliseconds: 30), () => futureTenant),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerLoadingWidget(
            itemHeight: 200,
            itemCount: 4,
            shimmerContainerHome: true,
          );
        }
        if (snapshot.hasError) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => showErrorBottomSheet());
          return const SizedBox();
        }
        fullTenant = snapshot.data ?? [];
        if (isFirstLoad) {
          foundTenant = fullTenant;
          isFirstLoad = false;
        }
        return foundTenant.isEmpty
            ? const ShimmerLoadingWidget(itemHeight: 200, itemCount: 4)
            : ListTenant(url: url, foundTenant: foundTenant);
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/core/constants.dart';
// import 'package:testgetdata/core/http/fetch_all_tenant.dart';
// import 'package:testgetdata/core/theme/colors_theme.dart';
// import 'package:testgetdata/data/model/tenant_model.dart';
// import 'package:testgetdata/data/provider/auth_provider.dart';
// import 'package:testgetdata/data/provider/coin_provider.dart';
// import 'package:testgetdata/presentation/widgets/carousel_widget.dart';
// import 'package:testgetdata/presentation/widgets/list_tenant.dart';
// import 'package:testgetdata/presentation/widgets/search_widget.dart';
// import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Future<List<TenantModel>> futureTenant;
//   final String url = "${MasbroConstants.url}/tenants";
//   List<TenantModel> foundTenant = [];
//   List<TenantModel> fullTenant = [];
//   bool isFirstLoad = true;

//   @override
//   void initState() {
//     super.initState();
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final user = authProvider.user;
//     futureTenant = fetchTenant(url, user.token);
//     context.read<CoinProvider>().fetchData(user.token);
//   }

//   void filterTenants(String value) {
//     setState(() {
//       foundTenant = value.isEmpty
//           ? fullTenant
//           : fullTenant.where((tenant) {
//               final searchString = (tenant.namaTenant +
//                       tenant.namaKavling +
//                       tenant.tenantFoods!.map((food) => food.nama).join(' '))
//                   .toLowerCase();
//               return searchString.contains(value.toLowerCase());
//             }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<AuthProvider>(context, listen: false).user;
//     if (!user.permission.contains('read beranda')) {
//       return const Center(child: Text('TIDAK ADA AKSES WOY'));
//     }

//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ));

//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             toolbarHeight: 35,
//             backgroundColor: AppColors.backgroundColor,
//             scrolledUnderElevation: 0,
//             automaticallyImplyLeading: false,
//             pinned: true,
//             floating: true,
//             expandedHeight: MediaQuery.of(context).size.width / 2.2,
//             flexibleSpace: Stack(
//               children: [
//                 Positioned.fill(
//                   child: FlexibleSpaceBar(
//                     background: CarouselWidget(),
//                   ),
//                 ),
//                 Positioned(
//                   top: MediaQuery.of(context).padding.top - 15,
//                   left: 15,
//                   right: 15,
//                   // bottom: 10,
//                   child: SearchWidget(
//                     paddingHorizontal: 0,
//                     paddingVertical: 0,
//                     formHeight: 43,
//                     tittle: "Cari menu kesukaanmu . . .",
//                     onChanged: filterTenants,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             sliver: SliverToBoxAdapter(
//               child: Text(
//                 'Saldo Koin: ${context.watch<CoinProvider>().saldoKoin}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: AppColors.textColorBlack,
//                 ),
//               ),
//             ),
//           ),
//           FutureBuilder<List<TenantModel>>(
//             future: futureTenant,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const SliverToBoxAdapter(
//                   child: ShimmerLoadingWidget(
//                     shimmerContainerHome: true,
//                     itemCount: 4,
//                     itemHeight: 200,
//                   ),
//                 );
//               }
//               if (snapshot.hasError) {
//                 return const SliverToBoxAdapter(child: SizedBox());
//               }
//               fullTenant = snapshot.data ?? [];
//               if (isFirstLoad) {
//                 foundTenant = fullTenant;
//                 isFirstLoad = false;
//               }
//               return foundTenant.isEmpty
//                   ? const SliverToBoxAdapter(
//                       child: ShimmerLoadingWidget(
//                         itemHeight: 200,
//                         itemCount: 4,
//                         showContainerTitle: false,
//                         showContainer: false,
//                       ),
//                     )
//                   : SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) => ListTenant(
//                           url: url,
//                           foundTenant: foundTenant,
//                         ),
//                         childCount: 1,
//                       ),
//                     );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
