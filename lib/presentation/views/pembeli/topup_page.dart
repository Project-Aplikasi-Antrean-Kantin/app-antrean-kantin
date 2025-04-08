import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class TopupPage extends StatefulWidget {
  final int coin;
  final String email;

  const TopupPage({
    super.key,
    required this.coin,
    required this.email,
  });

  @override
  _TopupPageState createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final List<int> nominalList = [5000, 10000, 25000, 50000, 100000, 200000];
  final TextEditingController _nominalController = TextEditingController();

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> openWhatsappChat() async {
    String nominal =
        _nominalController.text.isEmpty ? "0" : _nominalController.text;

    final String message = Uri.encodeComponent(
        "Halo, saya ingin melakukan topup koin dengan nominal Rp $nominal ke akun dengan email berikut: ${widget.email}. Mohon informasinya lebih lanjut.");

    final Uri whatsappUrl =
        Uri.parse('https://wa.me/6281218230764?text=$message');
    final Uri playStoreUrl =
        Uri.parse('https://play.google.com/store/apps/details?id=com.whatsapp');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // arahkan ke Play Store jika tidak ada telegram
      if (!await launchUrl(playStoreUrl,
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $playStoreUrl';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          automaticallyImplyLeading: true,
          toolbarHeight: 50,
          scrolledUnderElevation: 0,
          bottomOpacity: 0,
          title: Text(
            'TopUp',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row saldo coin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Saldo Koin: ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textColorBlack,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.toll,
                        size: 30,
                        color: Colors.yellow[700],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.coin}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.textColorBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Text Pilih Nominal
              Text(
                "Pilih Nominal",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: AppColors.textColorBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // GridView untuk memilih nominal
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3,
                  ),
                  itemCount: nominalList.length,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _nominalController.text =
                              nominalList[index].toString();
                        });
                      },
                      child: Text(
                        "${nominalList[index].toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => "${m[1]}.",
                            )}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Form field untuk menampilkan nominal yang dipilih
              TextFormField(
                readOnly: true,
                controller: _nominalController, // Tambahkan controller
                keyboardType: TextInputType.number,
                cursorColor: AppColors.primaryColor,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Jumlah koin',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),

        // bottom button redirect ke WA
        bottomNavigationBar: Container(
          height: 75,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            border: Border.all(
              width: 0.2,
              color: AppColors.containerColorGrey,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: ElevatedButton(
            onPressed: () {
              openWhatsappChat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Topup sekarang',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: semibold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
