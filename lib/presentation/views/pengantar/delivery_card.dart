import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class DeliveryCard extends StatelessWidget {
  final VoidCallback onSuccess;
  final Pesanan pesanan;
  final DeliveryStatus status;
  final String userToken;

  const DeliveryCard({
    Key? key,
    required this.onSuccess,
    required this.pesanan,
    required this.status,
    required this.userToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deliveryProvider =
        Provider.of<DeliveryProvider>(context, listen: false);
    final totalItemMenu = pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);
    final tenantName = pesanan.listTransaksiDetail.isNotEmpty &&
            pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant != null
        ? capitalizeFirstLetter(
            pesanan.listTransaksiDetail[0].menus!.tenants!.namaTenant)
        : 'Unknown Tenant';

    final isLoading = context.watch<DeliveryProvider>().isLoadingItem;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            label: 'Alamat pengantaran',
            value: pesanan.namaRuangan ?? '-',
            valueStyle: GoogleFonts.poppins(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: semibold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSection(
                label: 'Penerima',
                value: capitalizeFirstLetter(pesanan.namaPembeli ?? '-'),
                valueStyle: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
              _buildSection(
                label: 'No.',
                value: 'ORDER-${pesanan.id.toString().padLeft(3, '0')}',
                valueStyle: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey, height: 1),
          ),
          _buildSection(
            label: status == DeliveryStatus.siapDiantar
                ? 'Tempat Ambil'
                : 'Tenant',
            value: tenantName,
            valueStyle: GoogleFonts.poppins(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: bold,
            ),
          ),
          ...pesanan.listTransaksiDetail
              .map((item) => PesananItemWidget(
                    pesanan: item,
                    tolakPesanan: () {},
                    terimaPesanan: () {},
                  ))
              .toList(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey, height: 1),
          ),
          _buildCostSection(pesanan, totalItemMenu),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PrimaryButton(
                isLoading: isLoading,
                elevation: 0,
                width: screenSize.width * 0.5,
                height: screenSize.height * 0.05,
                borderRadius: 100,
                child: Text(
                  status == DeliveryStatus.siapDiantar
                      ? 'Antar Pesanan'
                      : 'Selesai Antar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  final success = await deliveryProvider.updateOrder(
                    status == DeliveryStatus.siapDiantar
                        ? 'diantar'
                        : 'selesai',
                    userToken,
                    pesanan.id,
                    pesanan,
                  );
                  log(deliveryProvider.errorMessage.toString());

                  Fluttertoast.showToast(
                    msg: success
                        ? status == DeliveryStatus.siapDiantar
                            ? 'Segera antar pesanan!'
                            : 'Pesanan selesai 🎉'
                        : deliveryProvider.errorMessage ??
                            'ORDER-${pesanan.id} telah diantar oleh driver lain',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: success ? Colors.grey : Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  if (success) onSuccess();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    String? label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? '',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 10,
              fontWeight: regular,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: valueStyle,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection(Pesanan pesanan, int totalItemMenu) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCostRow('Subtotal ($totalItemMenu menu)', pesanan.subTotal),
          const SizedBox(height: 10),
          _buildCostRow('Biaya layanan', pesanan.biayaLayanan),
          const SizedBox(height: 10),
          _buildCostRow('Ongkir', pesanan.ongkosKirim),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 14,
                  fontWeight: bold,
                ),
              ),
              Text(
                FormatCurrency.intToStringCurrency(pesanan.total),
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 14,
                  fontWeight: bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
            fontWeight: medium,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(amount),
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
            fontWeight: medium,
          ),
        ),
      ],
    );
  }
}
