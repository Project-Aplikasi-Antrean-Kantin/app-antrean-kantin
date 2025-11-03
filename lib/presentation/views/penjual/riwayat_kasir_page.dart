import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/penjual/history_transaction_cashier_item.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class RiwayatKasirPage extends StatefulWidget {
  const RiwayatKasirPage({super.key});

  @override
  State<RiwayatKasirPage> createState() => _RiwayatKasirPageState();
}

class _RiwayatKasirPageState extends State<RiwayatKasirPage> {
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
          print("click catat transaksi");
          final kasirProvider =
              Provider.of<KasirProvider>(context, listen: false);

          if (kasirProvider.tenant == null) return;
          Navigator.push(
              context,
              CustomPageBuilder(
                  page: MenuTenant(
                      fromCashier: true,
                      url:
                          "${MasbroConstants.url}/tenants/${kasirProvider.tenant?.id.toString()}")));
        },
        label: Text("Catat Transaksi",
            style: GoogleFonts.poppins(color: Colors.white)),
        icon: const Icon(Iconsax.add_copy, color: Colors.white),
      ),
      body: Consumer<KasirProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 8,
                );
              },
              itemCount: provider.cashierTransactions.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.cashierTransactions.length) {
                  return SizedBox(
                    height: 64,
                  );
                }
                final transaction = provider.cashierTransactions[index];
                return HistoryTransactionCashierItem(
                  transaction: transaction,
                  printer: printer,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
