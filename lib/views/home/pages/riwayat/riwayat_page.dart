import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_riwayat_transaksi.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/theme/colors.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/common/format_date.dart';
import 'package:testgetdata/views/home/pages/riwayat/detail_riwayat.dart';
import 'package:testgetdata/views/theme.dart';

class RiwayatPage extends StatefulWidget {
  // static const int RiwayatIndex = 1;
  final String role;

  const RiwayatPage({super.key, required this.role});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Pesanan> listPesanan = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    List<Pesanan> pesananList = await fetchRiwayat(user.token, widget.role);
    setState(() {
      isLoading = false;
      listPesanan = pesananList;
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Container(
                color: backgroundColor,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              )
            : listPesanan.isEmpty
                ? ListView(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 1.3,
                        color: Colors.transparent,
                        child: Center(
                          child: Text(
                            'Belum ada riwayat',
                            style: GoogleFonts.poppins(
                              color: primaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: Column(
                        children: listPesanan.map((pesanan) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetialRwiayat(
                                    pesanan: pesanan,
                                    refreshData: _refreshData,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 254, 254),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                "${pesanan.listTransaksiDetail[0].menus?.tenants?.gambar}",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          height: 80,
                                          width: 80,
                                          margin:
                                              const EdgeInsets.only(right: 15),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant}",
                                              style: GoogleFonts.poppins(
                                                color: secondaryTextColor,
                                                fontSize: 14,
                                                fontWeight: semibold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              FormatDate.formatDateTimeWithWIB(
                                                  pesanan.createdAt),
                                              style: GoogleFonts.poppins(
                                                color: primaryTextColor,
                                                fontSize: 12,
                                                fontWeight: regular,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "${pesanan.listTransaksiDetail[0].jumlah} Item Menu",
                                              style: GoogleFonts.poppins(
                                                color: primaryTextColor,
                                                fontSize: 12,
                                                fontWeight: medium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Divider(
                                      color: lineDividerColor,
                                      height: 1,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                              pesanan.total),
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            pesanan.status
                                                .replaceAll('_', ' ')
                                                .toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              color: getStatusColor(
                                                  pesanan.status),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
      ),
    );
  }
}
