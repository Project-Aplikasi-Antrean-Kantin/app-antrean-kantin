import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/action_pesanan_diproses.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/action_pesanan_masuk.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/action_pesanan_siap/action_pesanan_siap.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/cetak_pesanan_button.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card/widgets/header_pesanan_card.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/molecules/status_pesanan.dart';
import 'package:testgetdata/presentation/widgets/molecules/tipe_pesanan.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';

class PesananCard extends StatefulWidget {
  final Pesanan pesanan;
  final OrderStatus status;
  final String token;
  final List<Pesanan> listPesanan;
  final FlutterThermalPrinter printer;

  const PesananCard({
    Key? key,
    required this.pesanan,
    required this.status,
    required this.token,
    required this.listPesanan,
    required this.printer,
  }) : super(key: key);

  @override
  PesananCardState createState() => PesananCardState();
}

class PesananCardState extends State<PesananCard> {
  final textEditingController = new TextEditingController();
  final kodePenolakanController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.blackColor300,
        ),
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TipePesanan(isPriority: widget.pesanan.isPriority ?? 0),
                StatusPesanan(status: widget.pesanan.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text('Kode Pemesanan',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: semibold,
                            color: AppColors.blackColor))),
                Expanded(
                    child: Text(
                  '${widget.pesanan.kodePemesanan}',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: semibold,
                    color: AppColors.primaryColor,
                  ),
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: HeaderPesananCard(
              pesanan: widget.pesanan,
            ),
          ),

          DashedDivider(height: 2, color: AppColors.blackColor100),

          // Rincian Pesanan Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Detail Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 14,
                fontWeight: semibold,
              ),
            ),
          ),

          // List Menu Items
          ...widget.pesanan.listTransaksiDetail.map((item) {
            return PesananItemWidget(
              isTenant: true,
              pesanan: item,
            );
          }).toList(),
          DashedDivider(color: AppColors.blackColor100, height: 2),

          // Summary Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSummary(),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.only(
                bottom: widget.pesanan.status != 'pesanan_masuk' ? 0 : 16,
                left: 16,
                right: 16),
            child: _buildActionButton(context, widget.pesanan),
          ),
          if (widget.pesanan.status != 'pesanan_masuk')
            CetakPesananButton(
                printer: widget.printer, pesanan: widget.pesanan),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(widget.pesanan.subTotal),
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Pesanan pesanan) {
    switch (widget.status) {
      case OrderStatus.pesananMasuk:
        return ActionPesananMasuk(pesanan: pesanan);
      case OrderStatus.pesananDiproses:
        ActionPesananDiproses(
            pesanan: pesanan, listPesanan: widget.listPesanan);
      case OrderStatus.pesananSiapDiambil:
        return ActionPesananSiap(
            pesanan: pesanan, listPesanan: widget.listPesanan);
    }
    return const SizedBox.shrink();
  }
}
