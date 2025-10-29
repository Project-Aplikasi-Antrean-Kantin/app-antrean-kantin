import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class RiwayatPage extends StatefulWidget {
  final String role;
  final String tabLabel;

  const RiwayatPage({super.key, required this.role, required this.tabLabel});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  bool _hasInitialized = false;
  DateTime? _lastFetchTime;
  int selectedIndex = 0;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      if (_onMessageSubscription == null) {
        _onMessageSubscription =
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final title = message.data['title']?.toString().toLowerCase();
          final body = message.data['body']?.toString().toLowerCase();
          final transaksiId = body?.split(' ')[1].trim();
          print('transaksiId: $transaksiId');

          final isPureNumber = RegExp(r'^\d+$').hasMatch(transaksiId ?? '');

          print('transaksiId: $transaksiId');
          if (title != null &&
              transaksiId != 'pesanan' &&
              title.contains('pesanan') &&
              !title.contains('pesanan masuk') &&
              transaksiId != null &&
              isPureNumber) {
            TransactionRemoteDataSource()
                .getOrderById(authProvider.user.token, transaksiId)
                .then((pesanan) {
              historyProvider.updateSelectedPesanan(pesanan);
              historyProvider.updatedPesanan(pesanan, widget.role);
            });
          }
        });
      }
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          historyProvider.fetchHistory(
              context, authProvider.user, widget.role, false);
        }
      });
    });

    // Pastikan ini jalan sebelum UI render list
    _fetchDataIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data ketika app kembali dari background
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      historyProvider.loadUnreadMessages().then((_) {
        historyProvider.fetchHistory(
            context, authProvider.user, widget.role, false,
            forceRefresh: true);
        if (historyProvider.selectedPesanan != null) {
          final pesanan = historyProvider.selectedPesanan!;
          TransactionRemoteDataSource()
              .getOrderById(authProvider.user.token, pesanan.id.toString())
              .then((pesanan) {
            historyProvider.updateSelectedPesanan(pesanan);
            historyProvider.updatedPesanan(pesanan, widget.role);
          });
        }
      });
    }
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

  // Method untuk mengecek apakah perlu fetch data
  Future<void> _fetchDataIfNeeded({bool forceRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    final now = DateTime.now();
    final shouldRefresh = forceRefresh ||
        !_hasInitialized ||
        historyProvider.getListPesanan(widget.role).isEmpty ||
        (_lastFetchTime != null &&
            now.difference(_lastFetchTime!).inMinutes > 5);

    if (shouldRefresh && !historyProvider.getIsLoading(widget.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        historyProvider.fetchHistory(
            context, authProvider.user, widget.role, true);
        _lastFetchTime = now;
        _hasInitialized = true;
      });
    }
  }

  // Method yang dipanggil saat tab menjadi visible
  void _onTabVisible() {
    _fetchDataIfNeeded(forceRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Panggil _onTabVisible setiap kali build (ketika tab menjadi aktif)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTabVisible();
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: AppColors.backgroundColor,
        color: AppColors.primaryColor,
        onRefresh: () async {
          final historyProvider =
              Provider.of<HistoryProvider>(context, listen: false);
          await historyProvider.refreshHistory(context, user, widget.role);
          _lastFetchTime = DateTime.now();
        },
        child: Consumer<HistoryProvider>(
          builder: (context, historyProvider, _) {
            final isLoading = historyProvider.getIsLoading(widget.role);
            final errorMessage = historyProvider.getErrorMessage(widget.role);
            final allPesanan = historyProvider.getListPesanan(widget.role);

            final filteredStatuses = getFilteredStatuses(selectedIndex);
            final listPesanan = filteredStatuses.isEmpty
                ? allPesanan
                : allPesanan
                    .where(
                        (pesanan) => filteredStatuses.contains(pesanan.status))
                    .toList();
            final groupedPesanan = groupPesananByDate(listPesanan);

            return Container(
              color: AppColors.backgroundColor,
              height: MediaQuery.of(context).size.height,
              child: isLoading
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        spacing: 8,
                        children: [
                          const SizedBox(height: 8),
                          _buildListFilter(isLoading),
                          const SizedBox(height: 8),
                          Skeletonizer(
                              child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 8,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 5,
                            itemBuilder: (context, index) => _buildPesananItem(
                                Pesanan.getDummyPesanan(), context, isLoading),
                          )),
                        ],
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: errorMessage.contains('Failed host lookup') ||
                                  errorMessage.contains('Connection')
                              ? Column(
                                  spacing: 8,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                        image: const AssetImage(
                                            'assets/images/No-connection.png')),
                                    Text(
                                      'Upss Koneksimu Hilang!',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.whiteColor900,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Cek jaringan internet kamu dulu, ya.    Tenang, kami tetap nungguin kamu balik 😄',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF585858),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _fetchDataIfNeeded(forceRefresh: true);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 16),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                48,
                                        child: Center(
                                            child: Text('Coba Lagi',
                                                style: GoogleFonts.poppins(
                                                  color: AppColors.whiteColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ))),
                                      ),
                                    )
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      errorMessage,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: regular,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        historyProvider.fetchHistory(
                                            context, user, widget.role, true);
                                        _lastFetchTime = DateTime.now();
                                      },
                                      child: const Text("Coba Lagi"),
                                    ),
                                  ],
                                ),
                        )
                      : allPesanan.isEmpty
                          ? Center(
                              child: Text(
                                "Belum ada riwayat",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: regular,
                                  color: AppColors.textColorBlack,
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                spacing: 8,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildListFilter(isLoading),
                                  const SizedBox(height: 8),
                                  groupedPesanan.isNotEmpty
                                      ? Expanded(
                                          child: ListView(
                                            controller: _scrollController,
                                            padding: EdgeInsets.zero,
                                            children: [
                                              ...groupedPesanan.entries
                                                  .expand((entry) {
                                                final tanggal = entry.key;
                                                final daftarPesanan =
                                                    entry.value;

                                                return [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    child: Text(
                                                      tanggal,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight: semibold,
                                                        color: AppColors
                                                            .blackColor300,
                                                      ),
                                                    ),
                                                  ),
                                                  ...daftarPesanan.map(
                                                    (pesanan) =>
                                                        _buildPesananItem(
                                                            pesanan,
                                                            context,
                                                            isLoading),
                                                  ),
                                                ];
                                              }).toList(),

                                              // Tambahin skeleton di paling bawah kalau lagi loading
                                              if (historyProvider
                                                      .getLoadMoreData(
                                                          widget.role) ==
                                                  true)
                                                Skeletonizer(
                                                    child: _buildPesananItem(
                                                        Pesanan
                                                            .getDummyPesanan(),
                                                        context,
                                                        isLoading)),
                                            ],
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Image(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2,
                                                  image: const AssetImage(
                                                      "assets/images/404-Not-Found.png"),
                                                ),
                                                Text('Belum ada riwayat',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        color: AppColors
                                                            .blackColor400))
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
            );
          },
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
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // ⬅️ padding ditambahkan di sini
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

  Widget _buildListFilter(bool isLoading) {
    final List<String> statusList = [
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
    ];

    return Skeletonizer(
      enabled: isLoading,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: statusList[selectedIndex],
          items: statusList.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Row(
                children: [
                  Icon(Iconsax.tag, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(status,
                      style: GoogleFonts.poppins(
                          color: selectedIndex != 0
                              ? AppColors.primaryColor
                              : Colors.black,
                          fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            final index = statusList.indexOf(value);
            setState(() => selectedIndex = index);
          },
          onMenuStateChange: (isOpen) => setState(() {
            _isDropdownOpen = isOpen;
          }),

          // === Customisasi dropdown utama ===
          buttonStyleData: ButtonStyleData(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selectedIndex != 0
                      ? AppColors.primaryColor
                      : Colors.grey.shade300),
              color: Colors.white,
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              _isDropdownOpen ? Iconsax.arrow_up_1 : Iconsax.arrow_down,
              color: selectedIndex != 0 ? AppColors.primaryColor : Colors.black,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPesananItem(
      Pesanan pesanan, BuildContext context, bool isLoading) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final chatType = getChatType(pesanan, authProvider.user.nama);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final user = authProvider.user;
    final isThereNewChat =
        historyProvider.unreadMessagesList.contains(pesanan.id);

    final totalItemMenu = pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);
    final List<CartMenuModel> cartMenu = pesanan.toCartMenuList();

    return GestureDetector(
      onTap: () async {
        if (isLoading) return;
        isLoading = true;
        final internetConnection = await hasInternetAccess();
        // final prefs = await SharedPreferences.getInstance();
        if (!internetConnection) {
          Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
          return;
        }
        // prefs.remove("unread").then((_) {
        //   Fluttertoast.showToast(msg: "Berhasil membaca riwayat");
        // });
        // print("Saved unread: ${prefs.getString('unread')}");
        historyProvider.updateSelectedPesanan(pesanan);
        Navigator.of(context).push(
          CustomPageBuilder(
            page: DetailRiwayat(
              pesanan: pesanan,
              label: widget.tabLabel,
              token: user.token.toString(),
              refreshData: () {
                TransactionRemoteDataSource()
                    .getOrderById(
                        authProvider.user.token, pesanan.id.toString())
                    .then((pesanan) {
                  historyProvider.updateSelectedPesanan(pesanan);
                  historyProvider.updatedPesanan(pesanan, widget.role);
                });
                _lastFetchTime = DateTime.now();
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.whiteColor100,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ImageByUrl(
                      url: pesanan.listTransaksiDetail.isNotEmpty
                          ? pesanan.listTransaksiDetail[0].menus?.tenants
                                  ?.gambar ??
                              ''
                          : '',
                      height: 76,
                      width: 76,
                      fit: BoxFit.cover),
                ),
                Flexible(
                  child: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: pesanan.isPriority == 1
                                      ? AppColors.primaryColor
                                      : Colors.grey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              spacing: 2,
                              children: [
                                if (pesanan.isPriority == 1)
                                  Icon(Iconsax.flash_1,
                                      size: 16, color: AppColors.primaryColor),
                                Text(
                                  pesanan.isPriority == 1
                                      ? "Express"
                                      : "Reguler",
                                  style: GoogleFonts.poppins(
                                    color: pesanan.isPriority == 1
                                        ? AppColors.primaryColor
                                        : Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: getStatusColor(pesanan.status)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              spacing: 2,
                              children: [
                                Icon(getIconByStatus(pesanan.status),
                                    size: 16,
                                    color: getStatusColor(pesanan.status)),
                                Text(
                                  getStatus(pesanan.status),
                                  style: GoogleFonts.poppins(
                                    color: getStatusColor(pesanan.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          // HugeIcon(
                          //     icon: getIconByStatus(pesanan.status),
                          //     color: getStatusColor(pesanan.status)),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              pesanan.listTransaksiDetail.isNotEmpty
                                  ? pesanan.listTransaksiDetail[0].menus
                                          ?.tenants?.namaTenant ??
                                      '-'
                                  : '-',
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            FormatDate.dateTimeToStringDate(pesanan.createdAt),
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                          // HugeIcon(
                          //     icon: getIconByStatus(pesanan.status),
                          //     color: getStatusColor(pesanan.status)),
                        ],
                      ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       FormatDate.dateTimeToStringDate(pesanan.createdAt),
                      //       style: GoogleFonts.poppins(
                      //         color: AppColors.blackColor,
                      //         fontSize: 12,
                      //         fontWeight: FontWeight.w400,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 8),
                      //     // Expanded(
                      //     //   child: Text(
                      //     //     getStatus(pesanan.status),
                      //     //     textAlign: TextAlign.end,
                      //     //     style: GoogleFonts.poppins(
                      //     //       color: getStatusColor(pesanan.status),
                      //     //       fontSize: 12,
                      //     //       fontWeight: FontWeight.w400,
                      //     //     ),
                      //     //     overflow: TextOverflow.ellipsis,
                      //     //     maxLines: 2,
                      //     //     softWrap: false,
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                      Wrap(
                        spacing: 8, // Jarak antar item horizontal
                        runSpacing: 4, // Jarak antar baris
                        children: pesanan.listTransaksiDetail
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast =
                              index == pesanan.listTransaksiDetail.length - 1;

                          return Text(
                            "${item.menus?.nama}${isLast ? '' : ', '}",
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DashedDivider(height: 1, color: AppColors.blackColor100),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (pesanan.status == 'refund_selesai' ||
                    pesanan.status == 'selesai' ||
                    pesanan.status == 'pending' ||
                    pesanan.status == 'gagal_bayar')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        FormatCurrency.intToStringCurrency(pesanan.total),
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${pesanan.listTransaksiDetail.length} Menu',
                        style: GoogleFonts.poppins(
                          color: AppColors.blackColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                if (pesanan.status == 'refund_selesai' ||
                    pesanan.status == 'selesai' ||
                    pesanan.status == 'pending' ||
                    pesanan.status == 'gagal_bayar')
                  const Spacer(),
                if (pesanan.status != 'refund_selesai' &&
                    pesanan.status != 'selesai' &&
                    pesanan.status != 'pending' &&
                    pesanan.status != 'gagal_bayar' &&
                    !(widget.tabLabel == 'Jual' && pesanan.status == 'diantar'))
                  GestureDetector(
                    onTap: () async {
                      print("cek");
                      final connectivityResult = await hasInternetAccess();
                      print("yahaha");
                      // final prefs = await SharedPreferences.getInstance();
                      final canChatTenant = historyProvider.availableChatList
                              .contains(pesanan.id) &&
                          chatType == 'tenant';
                      if (!connectivityResult) {
                        Fluttertoast.showToast(
                          msg: 'Tidak ada koneksi internet',
                        );
                        showNoConnectionBottomSheet(
                          context: context,
                          onRetry: () {},
                        );
                        return;
                      }
                      if (chatType == 'tenant' && widget.tabLabel == 'Beli') {
                        if (!canChatTenant) {
                          Fluttertoast.showToast(
                              msg:
                                  "Harus tenant yang melakukan chat terlebih dahulu");
                          return;
                        }
                      }
                      await historyProvider.removeUnreadMessages(pesanan.id);
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: ChatPage(
                            pesanan: pesanan,
                            chatType: chatType,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip
                          .none, // supaya bulatan bisa keluar dari container
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.message,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                textAlign: TextAlign.center,
                                'Chat ${chatType == 'driver' ? widget.tabLabel == 'Antar' ? 'Pembeli' : 'Driver' : widget.tabLabel == 'Jual' ? 'Pembeli' : 'Penjual'}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.whiteColor900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isThereNewChat)
                          Positioned(
                            right: 4,
                            top: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (pesanan.status == 'pending' && widget.tabLabel == 'Beli')
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: CheckoutQris(
                            pesanan: pesanan,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip
                          .none, // supaya bulatan bisa keluar dari container
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Bayar',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                widget.tabLabel == 'Beli'
                    ? (pesanan.status == 'selesai' ||
                            pesanan.status == 'pesanan_ditolak' ||
                            pesanan.status == 'refund_selesai' ||
                            pesanan.status == 'gagal_bayar')
                        ? GestureDetector(
                            onTap: () async {
                              final connectivityResult =
                                  await hasInternetAccess();
                              if (!connectivityResult) {
                                Fluttertoast.showToast(
                                  msg: 'Tidak ada koneksi internet',
                                );
                                showNoConnectionBottomSheet(
                                    context: context, onRetry: () {});
                                return;
                              }
                              if (pesanan
                                      .listTransaksiDetail[0].menus?.tenants ==
                                  null) return;
                              cartProvider.setCurrentTenant(
                                  pesanan
                                      .listTransaksiDetail[0].menus!.tenants!,
                                  cartMenu);

                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                Navigator.push(
                                  context,
                                  CustomPageBuilder(
                                    page: MenuTenant(
                                        url:
                                            '${MasbroConstants.url}/tenants/${pesanan.listTransaksiDetail[0].menus!.tenants!.id.toString()}',
                                        cart: cartMenu),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Pesan Lagi',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: semibold,
                                ),
                              ),
                            ),
                          )
                        : Container()
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getChatType(Pesanan pesanan, String namaUser) {
    switch (pesanan.status) {
      case 'pesanan_masuk':
        return ((pesanan.driverId != null && widget.tabLabel == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'pesanan_diproses':
        return ((pesanan.driverId != null && widget.tabLabel == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'siap_diambil':
        return ((pesanan.driverId != null && widget.tabLabel == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'siap_diantar':
        return ((pesanan.driverId != null && widget.tabLabel == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'diantar':
        return 'driver';
      default:
        return 'proses';
    }
  }

  String getStatus(String status) {
    switch (status) {
      case 'refund_selesai':
        return 'Refund';
      case 'gagal_bayar':
        return 'Gagal Bayar';
      case 'pending':
        return 'Pending';
      case 'selesai':
        return 'Selesai';
      case 'pesanan_ditolak':
        return 'Ditolak';
      case 'pesanan_diproses':
        return 'Diproses';
      case 'pesanan_masuk':
        return 'Pesanan Masuk';
      case 'diantar':
        return 'Diantar';
      case 'siap_diambil':
        return 'Siap Diambil';
      case 'siap_diantar':
        return 'Siap Diantar';
      default:
        return '';
    }
  }

  IconData getIconByStatus(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return Iconsax.login_1_copy;
      case 'pesanan_diproses':
        return Iconsax.repeat;
      case 'siap_diantar':
        return Iconsax.reserve;
      case 'siap_diambil':
        return Iconsax.flag_2;
      case 'diantar':
        return Iconsax.routing;
      case 'selesai':
        return Iconsax.tick_circle;
      case 'gagal_bayar':
        return Iconsax.money_remove;
      case 'refund_selesai':
        return Iconsax.directbox_send;
      case 'pending':
        return HugeIcons.strokeRoundedLoading03;
      default:
        return HugeIcons.strokeRoundedArrowReloadVertical;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return AppColors.warningColor400;
      case 'pesanan_diproses':
        return AppColors.warningColor;
      case 'siap_diambil':
        return AppColors.secondaryColor;
      case 'siap_diantar':
        return AppColors.primaryColor300;

      case 'selesai':
        return AppColors.successColor;
      case 'pending':
        return AppColors.whiteColor600;
      case 'gagal_bayar':
        return AppColors.errorColor;
      case 'refund_selesai':
        return AppColors.blackColor;
      default:
        return AppColors.primaryColor;
    }
  }
}
