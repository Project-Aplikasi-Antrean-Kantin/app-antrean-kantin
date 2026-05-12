import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/income_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/penjual/detail_penghasilan.dart';
import 'package:testgetdata/presentation/widgets/bar_chart.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class PenghasilanPage extends StatefulWidget {
  const PenghasilanPage({super.key});

  @override
  State<PenghasilanPage> createState() => _PenghasilanPageState();
}

class _PenghasilanPageState extends State<PenghasilanPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      incomeProvider.clearProvider();
      incomeProvider.setSelectedSort("Minggu", authProvider.user.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.whiteColor100,
        surfaceTintColor: AppColors.backgroundColor,
        title: const Text("Pendapatan",
            style: TextStyle(
                color: AppColors.textColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
          child: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, child) => Skeletonizer(
          enabled: incomeProvider.isLoading,
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF4294FF), Color(0xFF0064E6)]))),
                if (incomeProvider.selectedIncome != null)
                  BarChartSample2(income: incomeProvider.selectedIncome!)
                else
                  const Center(child: Text("Belum ada data")),
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Pendapatan Tenant',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor400)),
              ),
              SizedBox(
                height: 8,
              ),
              if (!incomeProvider.isLoading)
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index ==
                        incomeProvider
                            .selectedIncome!.listIncomeTransaksi.keys.length) {
                      return const SizedBox(height: 12);
                    } else {
                      final label = incomeProvider
                          .selectedIncome!.listIncomeTransaksi.keys
                          .toList()[index];
                      final transaksiList = incomeProvider
                          .selectedIncome!.listIncomeTransaksi[label]!;

                      final keteranganWaktu = incomeProvider.selectedIncome!
                          .getLabelBySortInPendapatanSort(
                              incomeProvider.selectedSort, label);

                      // hitung total pendapatan untuk label ini
                      final totalPendapatan = transaksiList.fold<int>(
                        0,
                        (sum, trx) => sum + trx.pendapatanBersih,
                      );

                      return _buildPendapatan(
                          context, totalPendapatan, label, keteranganWaktu);
                    }
                  },

                  itemCount: incomeProvider
                          .selectedIncome?.listIncomeTransaksi.keys.length ??
                      0 + 1,
                  shrinkWrap: true, // <– biar ukurannya ngikut isi
                  physics:
                      const NeverScrollableScrollPhysics(), // <– nonaktifin scroll internal
                ),
              if (!incomeProvider.isLoading &&
                  incomeProvider
                      .selectedIncome!.listIncomeTransaksi.keys.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/images/not-found-pendapatan.svg',
                          width: 200),
                      Text(
                          "Yahh... data pendapatan pada periode ini tidak tersedia☹️",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor400)),
                      SizedBox(
                        height: 36,
                      )
                    ],
                  ),
                ),
            ]),
          ),
        ),
      )),
    );
  }

  Widget _buildPendapatan(BuildContext context, int totalPendapatan,
      String label, String keteranganWaktu) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          CustomPageBuilder(
              page: DetailPenghasilan(
            totalPendapatan: totalPendapatan,
            label: label,
          ))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          spacing: 16,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.infoColor100, shape: BoxShape.circle),
              child: HugeIcon(
                  icon: HugeIcons.strokeRoundedMoney03,
                  color: AppColors.primaryColor),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 2,
              children: [
                Text('${FormatCurrency.intToStringCoin(totalPendapatan)}',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor)),
                Text('$keteranganWaktu',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.blackColor300))
              ],
            ),
            Spacer(),
            HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: AppColors.primaryColor)
          ],
        ),
      ),
    );
  }
}
