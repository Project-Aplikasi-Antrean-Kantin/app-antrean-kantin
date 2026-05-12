import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/income_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/income_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class BarChartSample2 extends StatefulWidget {
  final Income income;
  BarChartSample2({super.key, required this.income});

  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 20;
  final ScrollController _scrollController = ScrollController();

  int touchedGroupIndex = -1;

  double maxY = 0;
  double maxYadded = 0;
  List<int> targets = [];
  int realMax = 0;
  List<int> filteredIndexes = [];

  List<int> generateTicks(int realMax, {int tickCount = 5}) {
    if (realMax <= 0) return [0];

    final step = (realMax / (tickCount - 1)).ceil();
    return List.generate(tickCount, (i) => i * step).map((e) {
      if (e > realMax) return realMax; // pastikan batas atas tetap realMax
      return e;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // cari nilai max dari kedua list
    final maxSelesai =
        widget.income.totalPesananSelesai.reduce((a, b) => a > b ? a : b);
    final maxRefund =
        widget.income.totalPesananRefund.reduce((a, b) => a > b ? a : b);

// ambil nilai max keseluruhan
    realMax = maxSelesai > maxRefund ? maxSelesai : maxRefund;
    maxY = (realMax * 1.2).toDouble(); // buat chart (dengan padding)

    targets = generateTicks(realMax, tickCount: 5);
    filteredIndexes = List.generate(
      widget.income.totalPesananSelesai.length,
      (index) => index,
    )
        .where((i) =>
            widget.income.totalPesananSelesai[i] > 0 ||
            widget.income.totalPesananRefund[i] > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        const SizedBox(height: 20),
        Consumer2<IncomeProvider, AuthProvider>(
          builder: (context, provider, auth, _) => Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 8),
                Text('Statistik Transaksi',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor400,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 8),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          provider.setSelectedSort('Minggu', auth.user.token),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: provider.selectedSort == 'Minggu'
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Minggu',
                            style: GoogleFonts.poppins(
                                fontWeight: provider.selectedSort == 'Minggu'
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: provider.selectedSort == 'Minggu'
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor300,
                                fontSize: 14)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          provider.setSelectedSort('Bulan', auth.user.token),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: provider.selectedSort == 'Bulan'
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Bulan',
                            style: GoogleFonts.poppins(
                                fontWeight: provider.selectedSort == 'Bulan'
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: provider.selectedSort == 'Bulan'
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor300,
                                fontSize: 14)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          provider.setSelectedSort('Tahun', auth.user.token),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: provider.selectedSort == 'Tahun'
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Tahun',
                            style: GoogleFonts.poppins(
                                fontWeight: provider.selectedSort == 'Tahun'
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: provider.selectedSort == 'Tahun'
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor300,
                                fontSize: 14)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                      FormatCurrency.intToStringCurrency(
                          widget.income.totalPendapatan),
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: AppColors.primaryColor)),
                ),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Row(
                    children: [
                      if (filteredIndexes.isNotEmpty)
                        IconButton(
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              color: AppColors.primaryColor),
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.offset - 120,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      if (filteredIndexes.isNotEmpty)
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bagian kiri: Sticky Left Titles (angka-angka Y)
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  3, // jumlah grid/label vertikal (atur sesuai kebutuhan)
                                  (i) {
                                    double value = (maxY / 5) * (5 - i);
                                    return SizedBox(
                                      height:
                                          40, // sesuaikan biar sejajar dengan bar chart
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(
                                  width: 8), // jarak antara Y axis dan chart

                              // Bagian kanan: chart yang bisa di-scroll horizontal
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: filteredIndexes.length * 100,
                                    child: BarChart(
                                      BarChartData(
                                        maxY: maxY,
                                        barTouchData: BarTouchData(
                                          touchTooltipData: BarTouchTooltipData(
                                            fitInsideHorizontally: true,
                                            fitInsideVertically: true,
                                            getTooltipColor: (group) =>
                                                Colors.black87,
                                            getTooltipItem: (group, groupIndex,
                                                rod, rodIndex) {
                                              final selesai =
                                                  group.barRods[0].toY.toInt();
                                              final refund =
                                                  group.barRods[1].toY.toInt();

                                              return BarTooltipItem(
                                                'Selesai: $selesai\nRefund/Ditolak: $refund',
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              reservedSize: 28,
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                int index = value.toInt();
                                                if (index < 0 ||
                                                    index >=
                                                        filteredIndexes
                                                            .length) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                final originalIndex =
                                                    filteredIndexes[index];
                                                final label = widget.income
                                                    .labels[originalIndex];

                                                return SideTitleWidget(
                                                  meta: meta,
                                                  space: 8,
                                                  child: Text(
                                                    label,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: List.generate(
                                            filteredIndexes.length, (i) {
                                          final index = filteredIndexes[i];
                                          return BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY: widget.income
                                                    .totalPesananSelesai[index]
                                                    .toDouble(),
                                                color: AppColors.successColor,
                                              ),
                                              BarChartRodData(
                                                toY: widget.income
                                                    .totalPesananRefund[index]
                                                    .toDouble(),
                                                color: AppColors.errorColor,
                                              ),
                                            ],
                                          );
                                        }),
                                        gridData: const FlGridData(show: false),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (filteredIndexes.isEmpty)
                        Expanded(
                          child: Text(
                            "Yahh.. sayangnya statistik transaksi periode ini tidak tersedia☹️",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: AppColors.blackColor400,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                            softWrap: true,
                          ),
                        ),
                      if (filteredIndexes.isNotEmpty)
                        IconButton(
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              color: AppColors.primaryColor),
                          onPressed: () {
                            _scrollController.animateTo(
                              _scrollController.offset + 120,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Row(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: AppColors.successColor,
                          ),
                        ),
                        Text('Selesai',
                            style: GoogleFonts.poppins(
                                color: AppColors.successColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: AppColors.errorColor)),
                        Text('Refund/Ditolak',
                            style: GoogleFonts.poppins(
                                color: AppColors.errorColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => provider.prevNewDate(auth.user.token),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor,
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: AppColors.whiteColor),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(spacing: 8, children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.infoColor200,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.infoColor300,
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCalendar01,
                                  color: AppColors.infoColor),
                            ),
                          ),
                          Text(
                              '${widget.income.getLabelBySort(provider.selectedSort, provider.date)}',
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontSize: 10,
                              ))
                        ])),
                    GestureDetector(
                      onTap: () => provider.nextNewDate(auth.user.token),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor,
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            color: AppColors.whiteColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = value.toString();
    } else if (value == 10) {
      text = value.toString();
    } else if (value == 19) {
      text = value.toString();
    } else {
      return Container();
    }
    return SideTitleWidget(
      meta: meta,
      space: 0,
      child: Text(text, style: style),
    );
  }
}
