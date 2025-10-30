import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class RiwayatKasirPage extends StatefulWidget {
  const RiwayatKasirPage({super.key});

  @override
  State<RiwayatKasirPage> createState() => _RiwayatKasirPageState();
}

class _RiwayatKasirPageState extends State<RiwayatKasirPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final kasirProvider = Provider.of<KasirProvider>(context, listen: false);

      kasirProvider.getListCashierTransaction(authProvider.user.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Catat Transaksi"),
        icon: const Icon(Icons.person),
      ),
      body: Consumer<KasirProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 8,
                );
              },
              itemCount: provider.cashierTransactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.cashierTransactions[index];
                return _buildTransactionItem(transaction, context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
      CashierTransaction transaction, BuildContext context) {
    final List<CartMenuModel> cartMenuList = transaction.toCartMenuList();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.whiteColor100,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]),
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageByUrl(
                    url: transaction.listTransaksiDetail.isNotEmpty
                        ? transaction.listTransaksiDetail[0].menus?.tenants
                                ?.gambar ??
                            ''
                        : '',
                    height: 76,
                    width: 76,
                    fit: BoxFit.cover),
              ),
              Flexible(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: getStatusColor(transaction.status)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            spacing: 2,
                            children: [
                              Icon(getIconByStatus(transaction.status),
                                  size: 16,
                                  color: getStatusColor(transaction.status)),
                              Text(
                                getStatus(transaction.status),
                                style: GoogleFonts.poppins(
                                  color: getStatusColor(transaction.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                        // HugeIcon(
                        //     icon: getIconByStatus(pesanan.status),
                        //     color: getStatusColor(pesanan.status)),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            transaction.listTransaksiDetail.isNotEmpty
                                ? transaction.listTransaksiDetail[0].menus
                                        ?.tenants?.namaTenant ??
                                    '-'
                                : '-',
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          FormatDate.dateTimeToStringDate(
                              transaction.createdAt),
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                        // HugeIcon(
                        //     icon: getIconByStatus(pesanan.status),
                        //     color: getStatusColor(pesanan.status)),
                      ],
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       FormatDate.dateTimeToStringDate(pesanan.createdAt),
                    //       style: GoogleFonts.poppins(
                    //         color: AppColors.blackColor,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w400,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 8),
                    //     // Expanded(
                    //     //   child: Text(
                    //     //     getStatus(pesanan.status),
                    //     //     textAlign: TextAlign.end,
                    //     //     style: GoogleFonts.poppins(
                    //     //       color: getStatusColor(pesanan.status),
                    //     //       fontSize: 12,
                    //     //       fontWeight: FontWeight.w400,
                    //     //     ),
                    //     //     overflow: TextOverflow.ellipsis,
                    //     //     maxLines: 2,
                    //     //     softWrap: false,
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                    Wrap(
                      spacing: 8, // Jarak antar item horizontal
                      runSpacing: 4, // Jarak antar baris
                      children: transaction.listTransaksiDetail
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast =
                            index == transaction.listTransaksiDetail.length - 1;

                        return Text(
                          "${item.menus?.nama}${isLast ? '' : ', '}",
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DashedDivider(height: 1, color: AppColors.blackColor100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  final connectivityResult = await hasInternetAccess();
                  if (!connectivityResult) {
                    Fluttertoast.showToast(
                      msg: 'Tidak ada koneksi internet',
                    );
                    showNoConnectionBottomSheet(
                        context: context, onRetry: () {});
                    return;
                  }
                  if (transaction.listTransaksiDetail[0].menus?.tenants == null)
                    return;
                  cartProvider.setCurrentTenant(
                      transaction.listTransaksiDetail[0].menus!.tenants!,
                      cartMenuList);

                  Navigator.push(
                    context,
                    CustomPageBuilder(
                      page: MenuTenant(
                        url:
                            '${MasbroConstants.url}/tenants/${transaction.listTransaksiDetail[0].menus!.tenants!.id.toString()}',
                        cart: cartMenuList,
                        cashierTransactionId: transaction.id.toString(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.infoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.message_edit, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('Edit',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
              ),
              Container()
            ],
          )
        ],
      ),
    );
  }

  String getStatus(String status) {
    switch (status) {
      case 'refund_selesai':
        return 'Refund';
      case 'gagal_bayar':
        return 'Gagal Bayar';
      case 'pending':
        return 'Pending';
      case 'selesai':
        return 'Selesai';
      case 'pesanan_ditolak':
        return 'Ditolak';
      case 'pesanan_diproses':
        return 'Diproses';
      case 'pesanan_masuk':
        return 'Pesanan Masuk';
      case 'diantar':
        return 'Diantar';
      case 'siap_diambil':
        return 'Siap Diambil';
      case 'siap_diantar':
        return 'Siap Diantar';
      default:
        return '';
    }
  }

  IconData getIconByStatus(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return Iconsax.login_1_copy;
      case 'pesanan_diproses':
        return Iconsax.repeat;
      case 'siap_diantar':
        return Iconsax.reserve;
      case 'siap_diambil':
        return Iconsax.flag_2;
      case 'diantar':
        return Iconsax.routing;
      case 'selesai':
        return Iconsax.tick_circle;
      case 'gagal_bayar':
        return Iconsax.money_remove;
      case 'refund_selesai':
        return Iconsax.directbox_send;
      case 'pending':
        return HugeIcons.strokeRoundedLoading03;
      default:
        return HugeIcons.strokeRoundedArrowReloadVertical;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return AppColors.warningColor400;
      case 'pesanan_diproses':
        return AppColors.warningColor;
      case 'siap_diambil':
        return AppColors.secondaryColor;
      case 'siap_diantar':
        return AppColors.primaryColor300;

      case 'selesai':
        return AppColors.successColor;
      case 'pending':
        return AppColors.whiteColor600;
      case 'gagal_bayar':
        return AppColors.errorColor;
      case 'refund_selesai':
        return AppColors.blackColor;
      default:
        return AppColors.primaryColor;
    }
  }
}
