import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/list_filter_dropdown.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/pesanan_item.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_empty_view.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_list_view/atom/date_header.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/riwayat_list_view/utils/multi_tenant_renderer.dart';

class RiwayatListView extends StatefulWidget {
  final bool isLoading;
  final String tabLabel;
  final String role;
  const RiwayatListView(
      {super.key,
      required this.isLoading,
      required this.tabLabel,
      required this.role});

  @override
  State<RiwayatListView> createState() => _RiwayatListViewState();
}

class _RiwayatListViewState extends State<RiwayatListView> {
  int selectedIndex = 0;
  bool _isDropdownOpen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          historyProvider.fetchHistory(
              context, authProvider.user, widget.role, false);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child:
          Consumer<HistoryProvider>(builder: (context, historyProvider, child) {
        final allPesanan = historyProvider.getListPesanan(widget.role);

        final filteredStatuses = getFilteredStatuses(selectedIndex);
        final listPesanan = filteredStatuses.isEmpty
            ? allPesanan
            : allPesanan
                .where((pesanan) => filteredStatuses.contains(pesanan.status))
                .toList();
        final groupedPesanan = groupPesananByDate(listPesanan);

        return Column(
          spacing: 8,
          children: [
            const SizedBox(height: 8),
            ListFilterDropdown(
                statusList: [
                  "Semua",
                  if (widget.tabLabel != "Antar") ...[
                    "Pesanan Masuk",
                    "Diproses",
                    "Siap Diambil",
                    "Siap Diantar",
                  ],
                  "Diantar",
                  "Selesai",
                  if (widget.tabLabel != "Antar") "Refund",
                ],
                isLoading: widget.isLoading,
                selectedIndex: selectedIndex,
                onChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                isDropdownOpen: _isDropdownOpen,
                onMenuStateChange: (bool isOpen) {
                  setState(() {
                    _isDropdownOpen = isOpen;
                  });
                }),
            const SizedBox(height: 8),
            groupedPesanan.isNotEmpty
                ? Expanded(
                    child: Consumer<HistoryProvider>(
                        builder: (context, historyProvider, child) {
                      return ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          ...groupedPesanan.entries.expand((entry) {
                            final tanggal = entry.key;
                            final daftarPesanan = entry.value;

                            return [
                              DateHeader(tanggal: tanggal),
                              ...MultiTenantRenderer.render(
                                daftarPesanan,
                                widget.role,
                                widget.tabLabel,
                              ),
                            ];
                          }),
                          if (historyProvider.getLoadMoreData(widget.role) ==
                              true)
                            Skeletonizer(
                              child: PesananItem(
                                pesanan: Pesanan.getDummyPesanan(),
                                role: widget.role,
                                tabLabel: widget.tabLabel,
                              ),
                            )
                        ],
                      );
                    }),
                  )
                : RiwayatEmptyView(),
          ],
        );
      }),
    );
  }

  Map<String, List<Pesanan>> groupPesananByDate(List<Pesanan> listPesanan) {
    Map<String, List<Pesanan>> grouped = {};

    for (var pesanan in listPesanan) {
      final dateStr = FormatDate.dateTimeToStringDate(pesanan.createdAt);

      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(pesanan);
    }

    return Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => b.value.first.createdAt
            .compareTo(a.value.first.createdAt)), // dari terbaru ke terlama
    );
  }

  List<String> getFilteredStatuses(int index) {
    switch (index) {
      // Misal: "Masuk"
      case 1:
        return ['pesanan_masuk'];

      case 2:
        return ['pesanan_diproses']; // "Diproses"
// "Ditolak"
      case 3:
        return ['siap_diambil']; // "Refund Selesai"
      case 4:
        return ['siap_diantar']; // "Selesai"
      case 5:
        return ['diantar']; // "Diantar"
      case 6:
        return ['selesai']; // "Siap Diambil"
      case 7:
        return ['refund_selesai'];
      case 0:
      default:
        return []; // Semua
    }
  }
}
