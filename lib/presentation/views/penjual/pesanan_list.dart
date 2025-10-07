import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';

class PesananList extends StatefulWidget {
  final OrderStatus status;
  final Future<void> Function() onRefresh;
  final FlutterThermalPrinter printer;

  const PesananList({
    Key? key,
    required this.status,
    required this.onRefresh,
    required this.printer,
  }) : super(key: key);

  @override
  State<PesananList> createState() => _PesananListState();
}

class _PesananListState extends State<PesananList> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 0;
  List<Pesanan> pesananList = [];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;

    final allPesanan = orderProvider.getPesananByStatus(widget.status);
    final keyword = _searchController.text.toLowerCase();

    pesananList = allPesanan.where((p) {
      final statusMatch = switch (selectedIndex) {
        1 => p.status == 'siap_diambil',
        2 => p.status == 'siap_diantar' || p.status == 'diantar',
        _ => true,
      };

      final keywordMatch =
          p.kodePemesanan?.toLowerCase().contains(keyword) ?? false;

      return statusMatch && (keyword.isEmpty || keywordMatch);
    }).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      child: Container(
        margin: EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          spacing: 16,
          children: [
            if (widget.status.rawValues.contains('siap_diambil'))
              SearchWidget(
                onChanged: (value) {
                  setState(() {}); // trigger rebuild saat input berubah
                },
                tittle: "Kode Pemesanan",
                paddingHorizontal: 0,
                paddingVertical: 0,
                controller: _searchController,
              ),
            if (widget.status.rawValues.contains('siap_diambil'))
              _buildListFilter(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pesananList.length,
                itemBuilder: (context, index) {
                  final pesananItem = pesananList[index];
                  return PesananCard(
                    listPesanan: pesananList,
                    pesanan: pesananItem,
                    status: widget.status,
                    token: user.token,
                    printer: widget.printer,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final isSelected = selectedIndex == index;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedIndex = index;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.primaryColor : Colors.transparent,
        side: BorderSide(color: AppColors.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isSelected ? Colors.white : AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildListFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          _buildFilterButton("Semua", 0),
          _buildFilterButton("Ambil Sendiri", 1),
          _buildFilterButton("Pesan Antar", 2),
        ],
      ),
    );
  }
}
