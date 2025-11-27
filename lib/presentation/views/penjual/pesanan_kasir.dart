import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/cashier_transaction_item_widget.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class PesananKasir extends StatefulWidget {
  final List<CashierTransaction> data;
  const PesananKasir({
    super.key,
    required this.data,
  });

  @override
  State<PesananKasir> createState() => _PesananKasirState();
}

class _PesananKasirState extends State<PesananKasir> {
  final FlutterThermalPrinter printer = FlutterThermalPrinter.instance;
  late StreamSubscription<RemoteMessage> _onCashierSuccess;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _onCashierSuccess =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.data['title']?.toString().toLowerCase();
        final body = message.data['body']?.toString().toLowerCase();
        final cashierId = body?.split(' ')[1].trim();
        print("cashierId: $cashierId title: $title");
        if (title!.contains('kasir') && cashierId != null) {
          final cleanId = int.parse(
            cashierId.replaceAll(RegExp(r'[^0-9]'), ''),
          );
          kasirProvider.getCashierTransactionById(
              authProvider.user.token, cleanId);
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _onCashierSuccess.cancel();
    super.dispose();
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                      height: 12,
                    ),
                itemCount: widget.data.length + 1,
                itemBuilder: (context, index) {
                  if (index == widget.data.length)
                    return SizedBox(
                      height: 64,
                    );
                  return CashierTransactionItemWidget(
                    printer: printer,
                    transaksi: widget.data[index],
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
