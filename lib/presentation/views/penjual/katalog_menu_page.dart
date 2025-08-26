import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_form.dart';
import 'package:testgetdata/presentation/views/penjual/menu_list_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/katalog_menu_tile.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class KatalogMenu extends StatefulWidget {
  const KatalogMenu({Key? key}) : super(key: key);

  @override
  State<KatalogMenu> createState() => _KatalogMenuState();
}

class _KatalogMenuState extends State<KatalogMenu> {
  Timer? _debounce;
  String _searchQuery = '';
  int selectedIndex = 0;
  bool isLoading = false;
  late UserModel user;

  List<TenantFoods> _filterMenu(String query, List<TenantFoods> data) {
    final filtered = query.isEmpty
        ? data
        : data.where((food) {
            return food.nama != null &&
                food.nama!.toLowerCase().contains(query.toLowerCase());
          }).toList();

    // Urutkan berdasarkan nama
    filtered.sort((a, b) {
      final nameA = a.nama?.toLowerCase() ?? '';
      final nameB = b.nama?.toLowerCase() ?? '';
      return nameA.compareTo(nameB);
    });

    // Kemudian urutkan berdasarkan isReady
    filtered.sort((a, b) {
      return (b.isReady ?? 0).compareTo(a.isReady ?? 0);
      // ubah `b` & `a` jika kamu ingin `isReady == 1` di bawah
    });

    // Filter berdasarkan selected index
    if (selectedIndex == 0) {
      return filtered;
    } else if (selectedIndex == 1) {
      return filtered.where((food) => food.isReady == 1).toList();
    } else {
      return filtered.where((food) => food.isReady == 0).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    // final user = context.read<AuthProvider>().user;
    // context.read<KatalogMenuProvider>().fetchData(user.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = context.read<AuthProvider>().user;
      context.read<KatalogMenuProvider>().fetchData(user.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          Consumer<KatalogMenuProvider>(builder: (context, provider, child) {
        return FloatingActionButton.extended(
          backgroundColor: AppColors.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          onPressed: () async {
            final internetConnection = await hasInternetAccess();
            if (!internetConnection) {
              Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
              return;
            }
            Navigator.push(
              context,
              CustomPageBuilder(page: KatalogMenuForm()),
            ).then((value) {
              if (value == true) {
                provider.fetchData(user.token);
              }
            });
          },
          label: Padding(
            padding: const EdgeInsets.all(16), // Padding 16 di semua sisi
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Supaya kontennya wrap
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAddCircle,
                  color: Colors.white,
                  size: 24,
                ),
                Text(
                  'Tambah',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<KatalogMenuProvider>(
          builder: (context, provider, child) {
            final filteredData = _filterMenu(_searchQuery, provider.data);

            if (provider.errorMessage != null) {
              return Center(child: Text(provider.errorMessage!));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                spacing: 16,
                children: [
                  // provider.isLoading
                  //     ? ShimmerCard(pageType: 'katalogMenuList')
                  //     : MenuListPage(isAvailable: true),
                  // provider.isLoading
                  //     ? ShimmerCard(pageType: 'katalogMenuList')
                  //     : MenuListPage(isAvailable: false),
                  SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowLeft02,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Katalog Menu',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SearchWidget(
                    paddingVertical: 0,
                    paddingHorizontal: 0,
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        setState(() {
                          _searchQuery = value;
                        });
                      });
                    },
                    tittle: "Cari menu . . .",
                  ),
                  Row(spacing: 8, children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedIndex == 0
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        side: BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      child: Text(
                        'Semua',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: selectedIndex == 0
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = 1;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedIndex == 1
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        side: BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      child: Text(
                        'Tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: selectedIndex == 1
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = 2;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedIndex == 2
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        side: BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      child: Text(
                        'Habis',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: selectedIndex == 2
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ]),
                  Expanded(
                    child: filteredData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  width: MediaQuery.of(context).size.width / 2,
                                  image: const AssetImage(
                                      "assets/images/404-Not-Found.png"),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada menu',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: AppColors.blackColor400),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredData.length + 1,
                            itemBuilder: (context, index) {
                              // final item = filteredData[index];

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                                child: filteredData.length == index
                                    ? SizedBox(height: 100)
                                    : KatalogMenuTile(
                                        key: ValueKey(
                                            '${filteredData[index].id}-${filteredData[index].isReady}'),
                                        item: filteredData[index],
                                        onChanged: (value) async {
                                          try {
                                            final result =
                                                await TenantRemoteDataSource()
                                                    .updateMenuisReady(
                                                        value,
                                                        user.token,
                                                        filteredData[index].id);
                                            if (result) {
                                              value == true
                                                  ? Fluttertoast.showToast(
                                                      msg: 'Menu Tersedia')
                                                  : Fluttertoast.showToast(
                                                      msg: 'Menu Habis');

                                              provider.updateStatusReady(
                                                  filteredData[index].id);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Gagal memperbarui status'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(
                                                'Error updating status: $e');
                                            Fluttertoast.showToast(
                                                msg: "Gagal mengupdate");
                                          }
                                        },
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
