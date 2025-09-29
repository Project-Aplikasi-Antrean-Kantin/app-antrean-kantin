import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/income_transaksi.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/income_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class DetailPenghasilan extends StatefulWidget {
  final String label;
  final int totalPendapatan;

  const DetailPenghasilan(
      {super.key, required this.label, required this.totalPendapatan});

  @override
  State<DetailPenghasilan> createState() => _DetailPenghasilanState();
}

class _DetailPenghasilanState extends State<DetailPenghasilan> {
  List<IncomeTransaksi> listIncome = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      setState(() {
        listIncome =
            incomeProvider.selectedIncome!.listIncomeTransaksi[widget.label] ??
                [];
        isLoading = false;
      });
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
        title: const Text("Laporan Pendapatan",
            style: TextStyle(
                color: AppColors.textColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Skeletonizer(
          enabled: isLoading,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.infoColor, width: 1),
                    color: AppColors.infoColor100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    spacing: 20,
                    children: [
                      HugeIcon(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          color: AppColors.infoColor),
                      Expanded(
                        child: Text(
                          "Nominal pesanan yang ditampilkan adalah nominal bersih yang diterima tenant, Nominal Pesanan = 0 (Refund Selesai)",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textColorBlack,
                          ),
                          softWrap: true,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    const Text("Total"),
                    Text(
                      FormatCurrency.intToStringCoin(widget.totalPendapatan),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                /// 🔥 Ganti Column+Row ke Table
                Expanded(
                  child: Column(
                    children: [
                      // Sticky header
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            children: [
                              _buildHeaderCell("No."),
                              _buildHeaderCell("No. Pesanan"),
                              _buildHeaderCell("Nominal Pesan"),
                              _buildHeaderCell("Detail"),
                            ],
                          ),
                        ],
                      ),

                      const Divider(height: 2, color: AppColors.blackColor100),
                      SizedBox(
                        height: 8,
                      ),

                      // Scrollable body
                      Expanded(
                        child: SingleChildScrollView(
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              ...listIncome.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                return TableRow(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: index.isEven
                                        ? AppColors.infoColor100
                                            .withOpacity(0.24)
                                        : AppColors.backgroundColor,
                                  ),
                                  children: [
                                    _buildDataCell("${index + 1}"),
                                    _buildDataCell("${item.id}"),
                                    _buildDataCell(
                                      FormatCurrency.intToStringCoin(
                                          item.pendapatanBersih),
                                    ),
                                    GestureDetector(
                                      onTap: () => TransactionRemoteDataSource()
                                          .getOrderById(authProvider.user.token,
                                              item.id.toString())
                                          .then((pesanan) {
                                        ShowBottomSheet(pesanan);
                                      }),
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.infoColor100,
                                        ),
                                        child: HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedTrolley01,
                                          size: 16,
                                          color: AppColors.infoColor,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  void ShowBottomSheet(Pesanan item) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
            child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            spacing: 8,
            children: [
              Text("No. Pesanan"),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "ORDER-${item.id.toString()}",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      _buildHeaderCell("Nama Menu"),
                      _buildHeaderCell("Jumlah"),
                      _buildHeaderCell("Harga"),
                    ],
                  ),
                ],
              ),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: [
                  ...item.listTransaksiDetail.asMap().entries.map((entry) {
                    final index = entry.key;
                    final detail = entry.value;

                    return TableRow(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: index.isEven
                            ? AppColors.infoColor100.withOpacity(0.24)
                            : Colors.white,
                      ),
                      children: [
                        _buildDataCell(detail.namaMenu),
                        _buildDataCell(detail.jumlah.toString()),
                        _buildDataCell(
                          FormatCurrency.intToStringCoin(detail.harga),
                        ),
                      ],
                    );
                  })
                ],
              )
            ],
          ),
        ));
      },
    );
  }

  Widget _buildDataCell(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textColorBlack,
          ),
        ),
      ),
    );
  }
}
