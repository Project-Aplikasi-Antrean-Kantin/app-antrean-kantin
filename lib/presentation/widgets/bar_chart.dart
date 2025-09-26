import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/income_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/income_provider.dart';

class BarChartSample2 extends StatefulWidget {
  final Income income;
  BarChartSample2({super.key, required this.income});
  final Color leftBarColor = AppColors.primaryColor;
  final Color rightBarColor = AppColors.secondaryColor;
  final Color avgColor = AppColors.warningColor;
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

    //  final barGroup1 = makeGroupData(10, 5, 12);
    // final barGroup2 = makeGroupData(1, 16, 12);
    // final barGroup3 = makeGroupData(2, 18, 5);
    // final barGroup4 = makeGroupData(3, 20, 16);
    // final barGroup5 = makeGroupData(4, 17, 6);
    // final barGroup6 = makeGroupData(5, 19, 1.5);
    // final barGroup7 = makeGroupData(6, 10, 1.5);
    // final barGroup8 = makeGroupData(6, 10, 1.5);
    // final barGroup9 = makeGroupData(6, 10, 1.5);
    // final barGroup10 = makeGroupData(6, 10, 1.5);
    // final barGroup11 = makeGroupData(6, 10, 1.5);
    // final barGroup12 = makeGroupData(6, 10, 1.5);

    // final items = [];

    // rawBarGroups = items;

    // showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text('Statistik Pendapatan',
            style: GoogleFonts.poppins(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
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
                Padding(
                  padding: const EdgeInsets.only(right: 24, bottom: 8, top: 8),
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.end,
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
                ),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Row(
                    children: [
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
                                    getTooltipColor: (group) => Colors.black87,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
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
                                  // touchCallback:
                                  //     (FlTouchEvent event, response) {
                                  //   if (response == null ||
                                  //       response.spot == null) {
                                  //     setState(() {
                                  //       touchedGroupIndex = -1;
                                  //       showingBarGroups =
                                  //           List.of(rawBarGroups);
                                  //     });
                                  //     return;
                                  //   }

                                  //   touchedGroupIndex =
                                  //       response.spot!.touchedBarGroupIndex;

                                  //   setState(() {
                                  //     if (!event.isInterestedForInteractions) {
                                  //       touchedGroupIndex = -1;
                                  //       showingBarGroups =
                                  //           List.of(rawBarGroups);
                                  //       return;
                                  //     }
                                  //     showingBarGroups = List.of(rawBarGroups);
                                  //     if (touchedGroupIndex != -1) {
                                  //       // var sum = 0.0;
                                  //       // for (final rod
                                  //       //     in showingBarGroups[touchedGroupIndex]
                                  //       //         .barRods) {
                                  //       //   sum += rod.toY;
                                  //       // }
                                  //       // final avg = sum /
                                  //       //     showingBarGroups[touchedGroupIndex]
                                  //       //         .barRods
                                  //       //         .length;

                                  //       // showingBarGroups[touchedGroupIndex] =
                                  //       //     showingBarGroups[touchedGroupIndex].copyWith(
                                  //       //   barRods: showingBarGroups[touchedGroupIndex]
                                  //       //       .barRods
                                  //       //       .map((rod) {
                                  //       //     return rod.copyWith(
                                  //       //         toY: avg, color: widget.avgColor);
                                  //       //   }).toList(),
                                  //       // );
                                  //     }
                                  //   });
                                  // },
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        final int rounded = value
                                            .round(); // bulatkan ke int terdekat

                                        // biar ga muncul duplikat, kita cek kalau yang ditampilkan
                                        // memang sama dengan value yg sudah dibulatkan (dalam toleransi kecil)
                                        if ((value - rounded).abs() < 0.5) {
                                          if (value == maxY) return Text("");
                                          return Text(
                                            rounded.toString(),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                          );
                                        }

                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      reservedSize: 28,
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();

                                        if (index < 0 ||
                                            index >= filteredIndexes.length) {
                                          return const SizedBox.shrink();
                                        }

                                        final originalIndex =
                                            filteredIndexes[index];
                                        final label =
                                            widget.income.labels[originalIndex];

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
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                barGroups:
                                    List.generate(filteredIndexes.length, (i) {
                                  final index = filteredIndexes[i];
                                  return BarChartGroupData(
                                    x: i, // pakai index rapat, bukan index asli
                                    barRods: [
                                      BarChartRodData(
                                        toY: widget
                                            .income.totalPesananSelesai[index]
                                            .toDouble(),
                                        color: AppColors.primaryColor,
                                      ),
                                      BarChartRodData(
                                        toY: widget
                                            .income.totalPesananRefund[index]
                                            .toDouble(),
                                        color: AppColors.secondaryColor,
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
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Text('Selesai',
                            style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
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
                                color: AppColors.secondaryColor)),
                        Text('Refund/Ditolak',
                            style: GoogleFonts.poppins(
                                color: AppColors.secondaryColor,
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

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: 10,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: 10,
        ),
      ],
    );
  }
}
