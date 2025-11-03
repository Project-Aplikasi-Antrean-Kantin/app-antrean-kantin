import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/cashier_transaction_item_widget.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class PesananKasir extends StatefulWidget {
  const PesananKasir({super.key});

  @override
  State<PesananKasir> createState() => _PesananKasirState();
}

class _PesananKasirState extends State<PesananKasir> {
  final FlutterThermalPrinter printer = FlutterThermalPrinter.instance;

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
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          final kasirProvider =
              Provider.of<KasirProvider>(context, listen: false);

          if (kasirProvider.tenant == null) return;
          Navigator.push(
              context,
              CustomPageBuilder(
                  page: MenuTenant(
                      fromCashier: true,
                      url:
                          "${MasbroConstants.url}/tenants/${kasirProvider.tenant!.id.toString()}")));
        },
        label: Text("Catat Transaksi",
            style: GoogleFonts.poppins(color: Colors.white)),
        icon: Icon(Iconsax.add_copy, color: Colors.white),
      ),
      body: Consumer<KasirProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final listPesananDiproses = provider.cashierTransactions
              .where((transaction) => transaction.status == "pesanan_diproses")
              .toList();
          print(
              "listIdPesananDiproses: ${listPesananDiproses.map((e) => e.id)}");
          print("listPesananDiproses: ${provider.cashierTransactions}");
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                      height: 12,
                    ),
                itemCount: listPesananDiproses.length + 1,
                itemBuilder: (context, index) {
                  if (index == listPesananDiproses.length)
                    return SizedBox(
                      height: 64,
                    );
                  return CashierTransactionItemWidget(
                    printer: printer,
                    transaksi: listPesananDiproses[index],
                    onTerima: () {},
                    onTolak: () {},
                    withPadding: true,
                  );
                }),
          );
        },
      ),
    );
  }
}
