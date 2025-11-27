import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/menu_tile.dart';

class ShimmerCard extends StatelessWidget {
  final String
      pageType; // Ganti isPageRiwayat dengan pageType untuk fleksibilitas

  ShimmerCard({
    Key? key,
    required this.pageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: pageType == 'riwayat'
            ? _buildRiwayatPageShimmer()
            : pageType == 'tenant'
                ? _buildTenantPageShimmer()
                : pageType == 'menuTenant'
                    ? _buildMenuTenantPageShimmer(context)
                    : pageType == 'katalogMenuList'
                        ? _buildMenuListPageShimmer()
                        : pageType == 'cartPage'
                            ? _buildCartPageShimmer()
                            : _buildCoinTransactionShimmer(context));
  }

  static Widget buildPesananPageShimmer(
      OrderStatus status, FlutterThermalPrinter printer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Skeletonizer(
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
            height: 8,
          ),
          itemBuilder: (context, index) => PesananCard(
            printer: printer,
            pesanan: Pesanan.getDummyPesanan(),
            status: status,
            token: "sad",
            listPesanan: [],
          ),
          itemCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
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
                  ? Color(0xFF12B76A)
                  : Color(0xFFF04438),
            ),
            const SizedBox(width: 4),
            Text(
              tenant.isOnline == true ? 'Buka' : 'Tutup',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: tenant.isOnline == true
                    ? Color(0xFF12B76A)
                    : Color(0xFFF04438),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '|',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? Color(0xFF12B76A)
                    : Color(0xFFF04438),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${tenant.jamBuka?.substring(0, 5) ?? '09:30'} - ${tenant.jamTutup?.substring(0, 5) ?? '17:00'}',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? Color(0xFF12B76A)
                    : Color(0xFFF04438),
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

  Widget _buildCartPageShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 10,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8), // ini kayak rounded-lg
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 16,
                          color: Colors.black,
                        ),
                        Container(
                          width: 30,
                          height: 16,
                          color: Colors.black,
                        ),
                        Container(
                          width: 80,
                          height: 24,
                          color: Colors.black,
                        ),
                      ]),
                  SizedBox(
                    width: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 50,
                      height: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: 10,
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        color: Colors.white,
                      ),
                      Container(
                        width: 100,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Container(width: 120, height: 36, color: Colors.white),
                ],
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(width: 120, height: 14, color: Colors.white),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 42,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 42,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100, height: 14, color: Colors.white),
                      Container(width: 80, height: 14, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 80, height: 16, color: Colors.white),
                      Container(width: 80, height: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatPageShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300] ?? Colors.grey,
        highlightColor: Colors.grey[100] ?? Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 120 * 0.8,
                      height: 14 - 2,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 120 * 0.6,
                      height: 14 - 2,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.grey, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120 * 0.7,
                  height: 14,
                  color: Colors.white,
                ),
                Container(
                  width: 120 * 0.5,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantPageShimmer() {
    return Container(
      margin: const EdgeInsets.only(right: 15, left: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Placeholder untuk gambar tenant
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Placeholder untuk konten bawah (nama, harga, kavling)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Placeholder untuk nama tenant
                        Container(
                          width: 150,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 5),
                        // Placeholder untuk deskripsi harga
                        Container(
                          width: 200,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  // Placeholder untuk kavling
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.3),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 16,
                        color: Colors.white,
                      ),
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

  Widget _buildMenuTenantPageShimmer(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Shimmer untuk SliverAppBar (header gambar)
        SliverAppBar(
          backgroundColor: AppColors.backgroundColor,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height / 4.5,
          flexibleSpace: Skeletonizer(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  color: Colors.white,
                ),
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
                            url: "",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: _buildTenantInfo(TenantModel(
                              transaksiBerhasil: 1,
                              id: 1,
                              namaTenant: "namaTenant",
                              namaKavling: "namaKavling",
                              gambar: "gambar",
                              userId: 1,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now())),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // Shimmer untuk nama tenant
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              width: 150,
              height: 50,
            ),
          ),
        ),
        // Shimmer untuk daftar MenuTile
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Skeletonizer(
                child: MenuTile(
                  tenant: TenantModel(
                      transaksiBerhasil: 1,
                      id: 2,
                      namaTenant: "namaTenant",
                      namaKavling: "namaKavling",
                      gambar: "gambar",
                      userId: 3,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now()),
                  food: TenantFoods(
                      id: 1,
                      nama: "nama",
                      kategoriId: 2,
                      gambar: "gambar",
                      isReady: 0,
                      deskripsi: "",
                      harga: 30000),
                  tenantName: "f",
                  isTenantMenu: true,
                  enableNotes: true,
                ),
              );
            },
            childCount: 4,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.8,
          ),
        ),

        // Ruang untuk FloatingActionButton
        SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildMenuListPageShimmer() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              // Placeholder untuk SearchWidget
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Placeholder untuk daftar KatalogMenuTile
              Column(
                children: List.generate(3, (index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Placeholder untuk gambar
                          Container(
                            width: 75,
                            height: 75,
                            margin: const EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          // Placeholder untuk detail
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 100,
                                  height: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 50,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          // Placeholder untuk switch
                          Container(
                            width: 50,
                            height: 30,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinTransactionShimmer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5, // Menampilkan 5 item shimmer untuk simulasi realistis
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      // Placeholder untuk ikon koin
                      Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Placeholder untuk kolom detail
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Placeholder untuk deskripsi
                              Container(
                                width: 200,
                                height: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 5),
                              // Placeholder untuk tanggal
                              Container(
                                width: 120,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Placeholder untuk jumlah koin
                      Container(
                        width: 80,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
