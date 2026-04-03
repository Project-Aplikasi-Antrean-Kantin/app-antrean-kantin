import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/history_transaction_cashier_item.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

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

  Map<DateTime, List<CashierTransaction>> groupTransactionsByDate(
    List<CashierTransaction> list,
  ) {
    // normalize ke yyyy-mm-dd (supaya jam tidak bikin beda)
    DateTime toDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    final Map<DateTime, List<CashierTransaction>> grouped = {};

    for (var trx in list) {
      final dateKey = toDate(trx.createdAt);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(trx);
    }

    // sort tiap grup berdasarkan orderTenant ASC
    grouped.forEach((key, value) {
      value.sort((a, b) => a.orderTenant.compareTo(b.orderTenant));
    });

    return grouped;
  }

  @override
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
                    "${MasbroConstants.url}/tenants/${kasirProvider.tenant?.id}",
              ),
            ),
          );
        },
        label: Text(
          "Catat Transaksi",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        icon: const Icon(Iconsax.add_copy, color: Colors.white),
      ),
      body: Consumer<KasirProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final grouped = groupTransactionsByDate(provider.cashierTransactions);

          final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          // Flatten: jadikan list berisi header + items
          final List<_ListItem> items = [];

          for (var date in dates) {
            items.add(_ListItem.header(date));
            for (var trx in grouped[date]!) {
              items.add(_ListItem.transaction(trx));
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (item.isHeader) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      FormatDate.dateTimeToStringDate(item.date!),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return HistoryTransactionCashierItem(
                  transaction: item.trx!,
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

class _ListItem {
  final DateTime? date;
  final CashierTransaction? trx;
  final bool isHeader;

  _ListItem.header(this.date)
      : trx = null,
        isHeader = true;

  _ListItem.transaction(this.trx)
      : date = null,
        isHeader = false;
}
