import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/views/home/widgets/custom_alert.dart';
import 'package:testgetdata/views/home/widgets/list_cart.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pemesanan.dart';
import 'package:testgetdata/views/home/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/views/home/widgets/ringkasan_pembayaran_cart.dart';
import 'package:testgetdata/views/home/widgets/sukses_order.dart';
import 'package:testgetdata/views/tenant/widgets/ringkasan_pembayaran_kasir.dart';
import 'package:testgetdata/views/theme.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController namaPembeli = TextEditingController();
  TextEditingController ruanganPembeli = TextEditingController();
  TextEditingController catatan = TextEditingController();

  List<Ruangan> listRuangan = [];
  late final MidtransSDK _midtrans;
  bool isLoading = false;
  bool transactionCompleted = false;
  int? plihPengantaran;
  int? pilihRuangan;
  String? pilihPembayaran;

  List<String> tipePemesanan = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  List<String> tipePembayaran = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  _dialogDataTidakLengkap() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlert(
          title: "Data Tidak Lengkap!",
          message:
              "Harap isi data pemesanan terlebih dahulu sebelum melanjutkan.",
          onConfirmCancle: () {
            Navigator.of(context).pop(); // Menutup dialog
          },
          textButtonCancel: "OK",
          textButtonCancelColor: primaryColor,
          cancelBorderColor: primaryColor,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Set the initial value of plihPengantaran and pilihRuangan to null
    plihPengantaran = null;
    pilihRuangan = null;
    pilihPembayaran = null;

    // Fetch the list of ruangan from the API using the user's token
    fetchDataRuangan(user.token).then((value) {
      setState(() {
        // Set the list of ruangan to the state of this widget
        listRuangan = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        title: Text(
          'Keranjang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              // The list of items in the cart
              Consumer2<CartProvider, KasirProvider>(
                builder: (context, cartProvider, kasirProvider, _) {
                  final activeCart = kasirProvider.cart.isNotEmpty
                      ? kasirProvider.cart
                      : cartProvider.cart;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),

                    // The number of items in the ListView
                    itemCount: activeCart.length,

                    // The builder function for the ListView
                    itemBuilder: (context, i) {
                      return ListCart(
                        cart: activeCart[i],
                        isKasir: kasirProvider.cart.isNotEmpty,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 15),

              // The form for selecting the type of delivery
              Consumer2<CartProvider, KasirProvider>(
                builder: (context, cartProvider, kasirProvider, _) {
                  final isKasirProviderActive = kasirProvider.cart.isNotEmpty;

                  return Column(
                    children: [
                      if (!isKasirProviderActive) ...[
                        // The type of delivery selector
                        PilihTipePemesanan(
                          tipePemesanan: tipePemesanan,
                          plihPengantaran: plihPengantaran,
                          onPemesananSelected: (option) {
                            setState(() {
                              plihPengantaran = option;
                              cartProvider.setIsAntar(option!);
                            });
                          },
                        ),

                        const SizedBox(height: 8),

                        // The location selector (only visible if the user selects "Pesan Antar")
                        if (plihPengantaran == 1)
                          PilihLokasiRuangan(
                            listRuangan: listRuangan,
                            token: user.token,
                            selectedLocation: pilihRuangan,
                            onLocationSelected: (option) {
                              setState(() {
                                pilihRuangan = option;
                                cartProvider.setRuanganId(option!);
                              });
                            },
                          ),
                        const SizedBox(height: 8),
                      ],

                      PilihTipePembayaran(
                        tipePembayaran: tipePembayaran,
                        pilihTipePembayaran: pilihPembayaran,
                        selectedPembayaran: (option2) {
                          setState(() {
                            pilihPembayaran = option2;
                            cartProvider.setMetodePembayaran(option2!);
                            kasirProvider.setMetodePembayaran(option2!);
                          });
                        },
                      ),

                      SizedBox(
                        height: 8,
                      ),
                      const SizedBox(height: 20),

                      // The summary of the order (either for the user or for the kasir)
                      isKasirProviderActive
                          ? RingkasanPembayaranKasir()
                          : RingkasanPembayaranCart(),
                      const SizedBox(height: 5),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // The bottom navigation bar
      bottomNavigationBar: context.watch<CartProvider>().isCartShow ||
              context.watch<KasirProvider>().isCartShow
          ? Consumer2<CartProvider, KasirProvider>(
              builder: (context, cartProvider, kasirProvider, _) {
                return Container(
                  margin: const EdgeInsets.all(15),
                  height: 63,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    // Whether the button is enabled or not
                    enableFeedback: !isLoading,

                    // The action to perform when the button is tapped
                    onTap: isLoading
                        ? () {}
                        : () {
                            // If the user hasn't selected any options, show a dialog
                            if (!kasirProvider.cart.isNotEmpty &&
                                !cartProvider.isCartValid(
                                    plihPengantaran, pilihRuangan)) {
                              _dialogDataTidakLengkap();
                            } else {
                              // Set the isLoading state to true
                              setState(() {
                                isLoading = true;
                                transactionCompleted = true;
                              });

                              // If the kasir provider is active, create a new transaction
                              if (kasirProvider.cart.isNotEmpty) {
                                kasirProvider
                                    .buatTransaksi(context, user.token)
                                    .then((value) {
                                  // Clear the cart
                                  kasirProvider.clearCart();

                                  // Navigate to the success page
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SuksesOrder(),
                                    ),
                                    (route) => false,
                                  );

                                  // Set the isLoading state to false
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else {
                                // Create a new transaction using the cart provider
                                cartProvider
                                    .buatTransaksi(context, user.token)
                                    .then((value) {
                                  // If the transaction is successful, navigate to the success page
                                  if (value.status == 'success') {
                                    if (value.snap != null) {
                                      // Start the payment flow
                                      _midtrans.startPaymentUiFlow(
                                        token: value.snap!.token,
                                      );
                                    } else {
                                      // Clear the cart
                                      cartProvider.clearCart();

                                      // Navigate to the success page
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SuksesOrder(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } else {
                                    print('gagal brooo');
                                  }

                                  // Set the isLoading state to false
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
                            }
                          },
                    child: Align(
                      alignment: Alignment.center,
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 4,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Tunggu sebentar",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Pesan sekarang",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }
}
