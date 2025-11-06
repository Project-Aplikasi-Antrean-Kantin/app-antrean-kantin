import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card.dart';

class DeliveryList extends StatelessWidget {
  final TabController? tabController;
  final DeliveryStatus status;
  final Future<void> Function() onRefresh;

  const DeliveryList({
    Key? key,
    required this.tabController,
    required this.status,
    required this.onRefresh,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final user = authProvider.user;
    final pesanan = deliveryProvider.getPesananByStatus(status);

    // 🔹 Grup berdasarkan multitenantId
    final groupedPesanan = <int?, List<Pesanan>>{};
    for (final item in pesanan) {
      final key = item.multitenantId; // bisa null
      if (!groupedPesanan.containsKey(key)) {
        groupedPesanan[key] = [];
      }
      groupedPesanan[key]!.add(item);
    }

    // 🔹 Ubah ke list (biar bisa pakai ListView.builder)
    final groupedList = groupedPesanan.entries.toList();

    return RefreshIndicator(
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: groupedList.length,
        itemBuilder: (context, index) {
          final tenantId = groupedList[index].key;
          final pesananList = groupedList[index].value;

          // 🔹 Kalau cuma 1 pesanan → tampilkan 1 card biasa
          if (pesananList.length == 1) {
            final pesananItem = pesananList.first;
            return DeliveryCard(
              ongkir: pesananItem.ongkosKirim,
              listTransaksiDetail: pesananItem.listTransaksiDetail,
              onSuccess: () => tabController?.animateTo(1),
              pesanan: pesananItem,
              status: status,
              userToken: user.token,
            );
          }
          final listTransaksiDetail = pesananList
              .expand((e) => e.listTransaksiDetail) // gabungkan semua
              .toSet() // hilangkan duplikat jika ada
              .toList();
          final ongkir = pesananList.fold<int>(
            0,
            (previousValue, element) => previousValue + element.ongkosKirim,
          );

          // 🔹 Kalau lebih dari 1 → bungkus dalam container
          return DeliveryCard(
            ongkir: ongkir,
            listTransaksiDetail: listTransaksiDetail,
            onSuccess: () => tabController?.animateTo(1),
            pesanan: pesananList.first,
            status: status,
            userToken: user.token,
          );
        },
      ),
    );
  }
}
