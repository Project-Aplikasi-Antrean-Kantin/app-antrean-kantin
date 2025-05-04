import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/coin_transaction_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
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
  int? _selectedNominal; // Track the selected nominal

  Future<void> openWhatsappChat({String? additionalMessage = ''}) async {
    String nominal = _selectedNominal?.toString() ?? "0";

    final String message = Uri.encodeComponent(
        "Verifikasi Topup Coin \n\nNominal: *Rp $nominal* \nEmail: *${widget.email}* \n\n$additionalMessage \n\nBerikut bukti pembayaran saya:\n_[Bukti bayar]_");

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
      if (!await launchUrl(playStoreUrl,
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $playStoreUrl';
      }
    }
  }

  void showQrisDialog() {
    String nominal = _selectedNominal?.toString() ?? "0";

    if (nominal == "0") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "Pengingat",
            message: "Silakan pilih nominal topup terlebih dahulu",
            showCancelButton: false,
            textButtonOk: "OK",
            onOkPressed: () => Navigator.of(context).pop(),
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pembayaran QRIS',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                Image.asset(
                  'assets/images/qris2.png',
                  height: 300,
                  width: 300,
                ),
                const SizedBox(height: 10),
                Text(
                  'Nominal Topup: Rp ${nominal.replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => "${m[1]}.",
                  )}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        minimumSize:
                            WidgetStateProperty.all(const Size(100, 30)),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        openWhatsappChat(
                          additionalMessage:
                              'Saya telah melakukan pembayaran via QRIS. Mohon untuk memverifikasi.',
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.primaryColor),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side:
                                const BorderSide(color: AppColors.primaryColor),
                          ),
                        ),
                        minimumSize:
                            WidgetStateProperty.all(const Size(100, 30)),
                      ),
                      child: Text(
                        'Kirim Bukti',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: semibold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    context.read<CoinProvider>().getHistoryCoin(user.token);
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              FormatCurrency.intToStringCoin(
                                widget.coin,
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: AppColors.textColorBlack,
                                fontWeight: semibold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Pilih Nominal",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: AppColors.textColorBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3,
                        ),
                        itemCount: nominalList.length,
                        itemBuilder: (context, index) {
                          final isSelected =
                              _selectedNominal == nominalList[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedNominal = nominalList[index];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withOpacity(0.1)
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.containerColorGrey,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${nominalList[index].toString().replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => "${m[1]}.",
                                      )}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.textColorBlack,
                                    fontWeight: isSelected ? semibold : regular,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        'List Transaksi',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<CoinProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.transactionCoin.isEmpty) {
                    return Center(child: Text('Tidak ada transaksi.'));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.transactionCoin.length,
                          itemBuilder: (context, index) {
                            final transaction = provider.transactionCoin[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 15),
                                    child: Icon(
                                      Icons.toll,
                                      size: 30,
                                      color: Colors.yellow[700],
                                    ),
                                  ),
                                  // ini di column
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // (transaction.deskripsi ?? ''),
                                            (transaction.deskripsi ?? '')
                                                .replaceAllMapped(
                                                    RegExp(r'#(\d+)'),
                                                    (m) =>
                                                        '#ORDER-0${m.group(1)}'),
                                            // .replaceAll(
                                            //     RegExp(r'\s*#\d+'), ''),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: regular,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            FormatDate.formatDateTimeWithWIB(
                                                transaction.createdAt),
                                            // transaction.createdAt.toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: semibold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    FormatCurrency.intToStringCoin(
                                      transaction.jumlah ?? 0,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: semibold,
                                      color: transaction.jumlah < 0
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
            onPressed: showQrisDialog,
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
