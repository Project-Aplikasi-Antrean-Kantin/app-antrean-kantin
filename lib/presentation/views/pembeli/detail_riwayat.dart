import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class DetialRwiayat extends StatelessWidget {
  final Pesanan pesanan;
  final VoidCallback refreshData;

  const DetialRwiayat({
    super.key,
    required this.pesanan,
    required this.refreshData,
  });

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final List<ListTransaksiDetail> pesananPembeli =
        pesanan.listTransaksiDetail;
    int subtotal = 0;
    int totalItem = 0;
    debugPrint(pesanan.createdAt.toString());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        automaticallyImplyLeading: true,
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        bottomOpacity: 0,
        title: Text(
          'Rincian Pesananmu',
          style: GoogleFonts.poppins(
            color: AppColors.secondaryTextColor,
            fontSize: 20,
            fontWeight: medium,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 254, 254),
                    border: Border.all(
                      color: AppColors.lineDividerColor,
                      width: 0.2,
                    ),
                    // borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          pesanan.status.replaceAll('_', ' ').toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: getStatusColor(pesanan.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: AppColors.lineDividerColor,
                          height: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alamat Pengantaran",
                              style: GoogleFonts.poppins(
                                color: AppColors.secondaryTextColor,
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              textAlign: TextAlign.left,
                              pesanan.namaRuangan ??
                                  capitalizeFirstLetter(
                                      'Tidak Diantar, Ambil Pesanan ke ${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant}'),
                              style: GoogleFonts.poppins(
                                color: AppColors.secondaryTextColor,
                                fontSize: 12,
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: AppColors.lineDividerColor,
                          height: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant}',
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryTextColor,
                            fontSize: 14,
                            fontWeight: semibold,
                          ),
                        ),
                      ),
                      ...pesananPembeli.map((item) {
                        int harga = item.harga;
                        int jumlah = item.jumlah;
                        subtotal += (harga * jumlah);
                        totalItem += jumlah;
                        return PesananItemWidget(
                          pesanan: item,
                          tolakPesanan: () {},
                          terimaPesanan: () {},
                        );
                      }).toList(),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal pesanan ($totalItem menu)",
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                            Column(children: [
                              Text(
                                FormatCurrency.intToStringCurrency(
                                  subtotal,
                                ),
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ])
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: AppColors.lineDividerColor,
                          height: 1,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Biaya layanan",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      FormatCurrency.intToStringCurrency(
                                        pesanan.biayaLayanan,
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (pesanan.isAntar == 1)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Ongkir",
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      // Menampilkan jumlah menu dikalikan dengan 10000
                                      Row(
                                        children: [
                                          Text(
                                            "$totalItem x",
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primaryTextColor,
                                              fontWeight: semibold,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            FormatCurrency.intToStringCurrency(
                                              1000,
                                            ),
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.secondaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      FormatCurrency.intToStringCurrency(
                                        pesanan.total,
                                      ),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.secondaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Divider(
                              color: AppColors.lineDividerColor,
                              height: 1,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rincinan Pesanan",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: semibold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "No Pesanan:",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                        fontWeight: regular,
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Text(
                                      pesanan.orderId,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                        fontWeight: regular,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Pembayaran:",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                        fontWeight: regular,
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Text(
                                      pesanan.metodePembayaran.toLowerCase() ==
                                              'cod'
                                          ? 'Bayar di Tempat'
                                          : capitalizeFirstLetter(
                                              pesanan.metodePembayaran),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                        fontWeight: regular,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Tanggal:",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                        fontWeight: regular,
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Text(
                                      FormatDate.formatDateTimeWithWIB(
                                          pesanan.createdAt),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryTextColor,
                                        fontSize: 12,
                                        fontWeight: regular,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
