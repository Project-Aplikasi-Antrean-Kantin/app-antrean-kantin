import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_form.dart';
import 'package:testgetdata/presentation/widgets/katalog_menu_tile.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';

class MenuListPage extends StatefulWidget {
  final bool isAvailable;

  const MenuListPage({Key? key, required this.isAvailable}) : super(key: key);

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<TenantFoods> _filterMenu(String query, List<TenantFoods> data) {
    final filtered = query.isEmpty
        ? data
        : data.where((food) {
            return food.nama != null &&
                food.nama!.toLowerCase().contains(query.toLowerCase());
          }).toList();
    return filtered
        .where((item) => item.isReady == (widget.isAvailable ? 1 : 0))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    return Consumer<KatalogMenuProvider>(
      builder: (context, provider, child) {
        final filteredData = _filterMenu(_searchQuery, provider.data);
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFB3B3B3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10, bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1)),
                          ),
                          child: Text(
                            'Makanan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (filteredData.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              'Tidak ada menu ditemukan',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          )
                        else
                          ...filteredData.map((item) => KatalogMenuTile(
                                item: item,
                                onChanged: (value) async {
                                  try {
                                    final result =
                                        await TenantRemoteDataSource()
                                            .updateMenuisReady(
                                                value, user.token, item.id);
                                    if (result) {
                                      await provider.fetchData(user.token);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Gagal memperbarui status'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('Error updating status: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Terjadi kesalahan'),
                                      ),
                                    );
                                  }
                                },
                              )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          floatingActionButton: widget.isAvailable
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const KatalogMenuForm()),
                      ).then((value) {
                        if (value == true) {
                          provider.fetchData(user.token);
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.05,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.02,
                            ),
                            child: Text(
                              'Tambah Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.038,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
