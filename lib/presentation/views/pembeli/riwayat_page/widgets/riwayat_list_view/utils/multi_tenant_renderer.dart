import 'package:flutter/widgets.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_list_view/molecule/multi_tenant_card.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/pesanan_item.dart';

class MultiTenantRenderer {
  static List<Widget> render(
      List<Pesanan> daftarPesanan, String role, String tabLabel) {
    List<Widget> widgets = [];

    List<Pesanan> currentGroup = [];
    int? currentTenantId;

    for (final pesanan in daftarPesanan) {
      final tenantId = pesanan.multitenantId;

      if (tenantId != null && tenantId == currentTenantId) {
        currentGroup.add(pesanan);
      } else {
        widgets.addAll(
            _renderGroup(currentGroup, currentTenantId, role, tabLabel));

        currentTenantId = tenantId;
        currentGroup = [pesanan];
      }
    }

    widgets.addAll(_renderGroup(currentGroup, currentTenantId, role, tabLabel));

    return widgets;
  }

  static List<Widget> _renderGroup(
      List<Pesanan> group, int? tenantId, String role, String tabLabel) {
    if (group.isEmpty) return [];

    if (group.length == 1) {
      return [
        PesananItem(
          pesanan: group.first,
          role: role,
          tabLabel: tabLabel,
        )
      ];
    }

    return [
      MultiTenantCard(
        tenantId: tenantId,
        pesananList: group,
        role: role,
        tabLabel: tabLabel,
      )
    ];
  }
}
