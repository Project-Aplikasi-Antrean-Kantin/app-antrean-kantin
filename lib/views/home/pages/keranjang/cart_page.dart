import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/views/home/widgets/bottom_navigation_button.dart';
import 'package:testgetdata/views/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/views/home/widgets/list_cart.dart';
import 'package:testgetdata/views/home/widgets/custom_alert.dart';
import 'package:testgetdata/views/home/widgets/sukses_order.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pemesanan.dart';
import 'package:testgetdata/views/home/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/views/home/widgets/ringkasan_pembayaran_cart.dart';
import 'package:testgetdata/views/tenant/widgets/ringkasan_pembayaran_kasir.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Controllers for
  final TextEditingController namaPembeli = TextEditingController();
  final TextEditingController ruanganPembeli = TextEditingController();
  final TextEditingController catatan = TextEditingController();

  // Ruangan-related
  List<Ruangan> listRuangan = [];

  // Midtrans SDK
  late final MidtransSDK _midtrans;

  // Transaction state
  bool transactionCompleted = false;
  int? pilihPengantaran;
  int? pilihRuangan;
  String? pilihPembayaran;

  // Tipe pemesanan dan pembayaran
  final List<String> tipePemesanan = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  final List<String> tipePembayaran = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  void _dialogDataTidakLengkap() {
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

  void handleTransaction(
    BuildContext context,
    KasirProvider kasirProvider,
    CartProvider cartProvider,
    UserModel user,
    int? plihPengantaran,
    int? pilihRuangan,
  ) {
    // If the user hasn't selected any options, show a dialog
    if (!kasirProvider.cart.isNotEmpty &&
        !cartProvider.isCartValid(plihPengantaran, pilihRuangan)) {
      _dialogDataTidakLengkap();
    } else {
      // Set the isLoading state to true
      cartProvider.setTransactionStatus(
        isLoading: true,
        isTransactionCompleted: true,
      );

      // If the kasir provider is active, create a new transaction
      if (kasirProvider.cart.isNotEmpty) {
        kasirProvider.buatTransaksi(context, user.token).then((value) {
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

          cartProvider.setTransactionStatus(
            isLoading: false,
          );
        });
      } else {
        // Create a new transaction using the cart provider
        cartProvider.createTransaction(context, user.token).then((value) {
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
                  builder: (context) => const SuksesOrder(),
                ),
                (route) => false,
              );
            }
          } else {
            print('gagal brooo');
          }

          // Set the isLoading state to false
          cartProvider.setTransactionStatus(
            isLoading: false,
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Set the initial value of plihPengantaran and pilihRuangan to null
    pilihPengantaran = null;
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
                          plihPengantaran: pilihPengantaran,
                          onPemesananSelected: (option) {
                            setState(() {
                              pilihPengantaran = option;
                              cartProvider.setIsDelivery(option!);
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        // The location selector (only visible if the user selects "Pesan Antar")
                        if (pilihPengantaran == 1)
                          PilihLokasiRuangan(
                            listRuangan: listRuangan,
                            token: user.token,
                            selectedLocation: pilihRuangan,
                            onLocationSelected: (option) {
                              setState(() {
                                pilihRuangan = option;
                                cartProvider.setIdRoom(option!);
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
                            cartProvider.setPaymentMethod(option2!);
                            kasirProvider.setMetodePembayaran(option2);
                          });
                        },
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
      bottomNavigationBar: context.watch<CartProvider>().isCartVisible ||
              context.watch<KasirProvider>().isCartShow
          ? Consumer2<CartProvider, KasirProvider>(
              builder: (context, cartProvider, kasirProvider, _) {
                return BottomNavigationButton(
                  isLoading: cartProvider.isLoading,
                  color: primaryColor,
                  onTap: () {
                    handleTransaction(
                      context,
                      kasirProvider,
                      cartProvider,
                      user,
                      pilihPengantaran,
                      pilihRuangan,
                    );
                  },
                );
              },
            )
          : null,
    );
  }
}
