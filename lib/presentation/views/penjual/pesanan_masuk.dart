import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/widgets/pesanan_card.dart';

class PesananMasuk extends StatelessWidget {
  final List<Pesanan> pesananMasuk;
  final Function(int, Pesanan, String) terimaPesanan;
  final Function(int, Pesanan, String) tolakPesanan;
  final Future<void> Function() onRefresh;

  const PesananMasuk({
    Key? key,
    required this.pesananMasuk,
    required this.terimaPesanan,
    required this.tolakPesanan,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
            ),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pesananMasuk.length,
                  itemBuilder: (BuildContext context, int index) {
                    final pesanan = pesananMasuk[index];
                    return PesananCard(
                      pesanan: pesanan,
                      actionButton: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // widget.removePesanan(pesanan, user.token);
                              tolakPesanan(pesanan.id, pesanan, user.token);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: AppColors.primaryColor),
                              backgroundColor: AppColors.backgroundColor,
                              minimumSize: Size(20, 30),
                              fixedSize: Size(160, 30),
                            ),
                            child: Text(
                              'Tolak',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // widget.removePesanan(pesanan, user.token);
                              terimaPesanan(pesanan.id, pesanan, user.token);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: AppColors.primaryColor),
                              backgroundColor: AppColors.primaryColor,
                              minimumSize: Size(20, 30),
                              fixedSize: Size(160, 30),
                            ),
                            child: Text(
                              'Terima',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
