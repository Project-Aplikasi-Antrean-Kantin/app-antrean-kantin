import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/widgets/pesanan_card.dart';

class PesananDiproses extends StatefulWidget {
  final List<Pesanan> pesananDiproses;
  final Function(Pesanan, String) removePesanan;

  const PesananDiproses({
    Key? key,
    required this.pesananDiproses,
    required this.removePesanan,
  }) : super(key: key);

  @override
  _PesananDiprosesState createState() => _PesananDiprosesState();
}

class _PesananDiprosesState extends State<PesananDiproses> {
  List<Pesanan> _pesananDiproses = [];

  @override
  void initState() {
    super.initState();
    _pesananDiproses = widget.pesananDiproses;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    return RefreshIndicator(
      onRefresh: _refresh,
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
                  itemCount: _pesananDiproses.length,
                  itemBuilder: (BuildContext context, int index) {
                    final pesanan = _pesananDiproses[index];

                    return PesananCard(
                      pesanan: pesanan,
                      actionButton: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              widget.removePesanan(pesanan, user.token);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(color: AppColors.primaryColor),
                              backgroundColor: AppColors.primaryColor,
                              minimumSize: Size(20, 30),
                              fixedSize: Size(180, 30),
                            ),
                            child: Text(
                              'Pesanan Siap',
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

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // Add refresh logic here if needed
  }
}
