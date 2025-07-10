import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class DetailRiwayat extends StatelessWidget {
  final Pesanan pesanan;
  final VoidCallback refreshData;
  final String token;

  const DetailRiwayat({
    super.key,
    required this.pesanan,
    required this.refreshData,
    required this.token,
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

    for (var item in pesananPembeli) {
      // subtotal dari BE masih bermasalah, sementara pakai ini
      subtotal += item.menus!.harga * item.jumlah;
      totalItem += item.jumlah;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        backgroundColor: AppColors.backgroundColor,
        color: AppColors.primaryColor,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              children: [
                _buildStatus(pesanan.status),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 10),
                _buildAlamatPengantaran(pesanan),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 10),
                _buildTenantTitle(pesanan),
                const SizedBox(height: 10),
                ...pesananPembeli.map((item) => PesananItemWidget(
                      pesanan: item,
                      tolakPesanan: () {},
                      terimaPesanan: () {},
                    )),
                const SizedBox(height: 10),
                _buildSubtotalSection(pesanan, totalItem),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 10),
                _buildBiayaLainSection(pesanan),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 10),
                _buildRincianPesanan(pesanan),
                const SizedBox(height: 30),
                // _buildButton(pesanan.status, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      toolbarHeight: 50,
      scrolledUnderElevation: 0,
      title: Text(
        'Rincian Pesananmu',
        style: GoogleFonts.poppins(
          color: AppColors.textColorBlack,
          fontSize: 18,
          fontWeight: semibold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildButton(String status, BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    if (status != 'siap_diambil') return Container();
    return Container(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Selesaikan Pesanan',
            style: GoogleFonts.poppins(
              color: AppColors.backgroundColor,
              fontSize: 14,
              fontWeight: semibold,
            ),
          ),
          onPressed: () async {
            print("MENCOBA UPDATE ORDER");
            final success = await orderProvider.updateOrder(
              'selesai',
              token,
              pesanan.id,
              pesanan,
            );
            print("STATUS UPDATE: $success");

            if (success) {
              Fluttertoast.showToast(
                msg: "Pesanan Selesai",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Navigator.of(context).pop();
            } else {
              Fluttertoast.showToast(
                msg: "Gagal menyelesaikan pesanan",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          }),
    );
  }

  Widget _buildStatus(String status) {
    return Center(
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: GoogleFonts.poppins(
          color: getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.lineDividerColor,
      height: 1,
    );
  }

  Widget _buildAlamatPengantaran(Pesanan pesanan) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alamat Pengantaran",
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 14,
              fontWeight: semibold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pesanan.isAntar == 1
                ? pesanan.namaRuangan ?? '-'
                : capitalizeFirstLetter(
                    'Tidak Diantar, Ambil Pesanan ke ${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant}'),
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 12,
            ),
            maxLines: 3,
          )
        ],
      ),
    );
  }

  Widget _buildTenantTitle(Pesanan pesanan) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant ?? '-',
        style: GoogleFonts.poppins(
          color: AppColors.textColorBlack,
          fontSize: 14,
          fontWeight: semibold,
        ),
      ),
    );
  }

  Widget _buildSubtotalSection(Pesanan pesanan, int totalItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Subtotal pesanan (${totalItem} menu)",
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(pesanan.subTotal),
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBiayaLainSection(Pesanan pesanan) {
    return Column(
      children: [
        _buildRowText("Biaya layanan", pesanan.biayaLayanan),
        if (pesanan.isAntar == 1) const SizedBox(height: 10),
        if (pesanan.isAntar == 1) _buildRowText("Ongkir", pesanan.ongkosKirim),
        const SizedBox(height: 10),
        _buildRowText("Total", pesanan.total, bold: true),
      ],
    );
  }

  Widget _buildRowText(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(value),
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildRincianPesanan(Pesanan pesanan) {
    log(pesanan.metodePembayaran.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rincinan Pesanan",
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 14,
            fontWeight: semibold,
          ),
        ),
        const SizedBox(height: 6),
        _buildInfoRow("No Pesanan:", pesanan.orderId),
        _buildInfoRow(
          "Pembayaran:",
          pesanan.metodePembayaran.toLowerCase() == 'cod'
              ? 'Bayar di Tempat'
              : capitalizeFirstLetter(pesanan.metodePembayaran),
        ),
        _buildInfoRow(
          "Tanggal:",
          FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
        ),
        _buildInfoRow(
          "Kode Pemesanan:",
          pesanan.kodePemesanan ?? '-',
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
