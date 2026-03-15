import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/list_filter_dropdown.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/pesanan_item.dart';

class RiwayatLoadingView extends StatelessWidget {
  final bool isLoading;
  final String tabLabel;
  final String role;

  const RiwayatLoadingView(
      {super.key,
      required this.isLoading,
      required this.tabLabel,
      required this.role});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        spacing: 8,
        children: [
          const SizedBox(height: 8),
          ListFilterDropdown(
              statusList: [
                "Semua",
                if (tabLabel != "Antar") ...[
                  "Pesanan Masuk",
                  "Diproses",
                  "Siap Diambil",
                  "Siap Diantar",
                ],
                "Diantar",
                "Selesai",
                if (tabLabel != "Antar") "Refund",
              ],
              isLoading: isLoading,
              selectedIndex: 0,
              onChanged: (index) {},
              isDropdownOpen: false,
              onMenuStateChange: (bool isOpen) {}),
          const SizedBox(height: 8),
          Skeletonizer(
              child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 8,
                      ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) => PesananItem(
                      pesanan: Pesanan.getDummyPesanan(),
                      role: role,
                      tabLabel: tabLabel))),
        ],
      ),
    );
  }
}
