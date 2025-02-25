import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/core/http/fetch_data_ruangan.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/widgets/list_cart.dart';
import 'package:testgetdata/presentation/widgets/custom_alert.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';
import 'package:testgetdata/presentation/widgets/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/presentation/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/presentation/widgets/bottom_navigation_button.dart';
import 'package:testgetdata/presentation/widgets/ringkasan_pembayaran_cart.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Ruangan-related
  List<Ruangan> _roomList = [];

  // Midtrans SDK
  late final MidtransSDK _midtrans;

  // Transaction state
  int? _selectedRoom;
  // int? _selectedDeliveryOption;
  String? _selectedPaymentMethod;
  bool transactionCompleted = false;

  final List<String> _paymentType = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  void _incompleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlert(
          title: "Data Tidak Lengkap!",
          message:
              "Harap isi data pemesanan terlebih dahulu sebelum melanjutkan.",
          onConfirmCancle: () {
            Navigator.of(context).pop(); // close dialog
          },
          textButtonCancel: "OK",
          textButtonCancelColor: AppColors.primaryColor,
          cancelBorderColor: AppColors.primaryColor,
        );
      },
    );
  }

  void handleTransaction(
    BuildContext context,
    KasirProvider kasirProvider,
    CartProvider cartProvider,
    UserModel user,
    int? selectRoom,
  ) {
    // If the user hasn't selected any options, show a dialog
    if (!kasirProvider.cart.isNotEmpty &&
        !cartProvider.isCartValid(selectRoom)) {
      _incompleteDataDialog();
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
              builder: (context) => const OrderSuccess(),
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
                  builder: (context) => const OrderSuccess(),
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
    _selectedRoom = null;
    _selectedPaymentMethod = "Transfer";

    // Fetch the list of ruangan from the API using the user's token
    fetchDataRuangan(user.token).then((value) {
      setState(() {
        // Set the list of ruangan to the state of this widget
        _roomList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            fontWeight: medium,
            fontSize: 18,
            color: AppColors.textColorBlack,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: AppColors.textColorBlack,
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
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Lokasi Pengantaran',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: semibold,
                                  color: AppColors.textColorBlack,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ToggleSwitch(
                              initialLabelIndex: context
                                          .read<CartProvider>()
                                          .selectedDeliveryOption ==
                                      1
                                  ? 0
                                  : 1,
                              minWidth: (screenSize.width - 30) / 2,
                              labels: const ['Pesan Antar', 'Ambil Sendiri'],
                              activeBgColor: [AppColors.primaryColor],
                              activeFgColor: AppColors.backgroundColor,
                              activeBorders: [
                                Border.all(color: AppColors.primaryColor)
                              ],
                              inactiveFgColor: AppColors.secondaryTextColor,
                              inactiveBgColor: AppColors.backgroundColor,
                              borderColor: [AppColors.secondaryTextColor],
                              borderWidth: 1,
                              cornerRadius: 5,
                              onToggle: (index) {
                                context
                                    .read<CartProvider>()
                                    .setDeliveryOption(index == 0 ? 1 : 0);
                              },
                            ),
                          ],
                        ),

                        // The location selector (only visible if the user selects "Pesan Antar")
                        if (context
                                .read<CartProvider>()
                                .selectedDeliveryOption ==
                            1)
                          Column(
                            children: [
                              SizedBox(height: 20),
                              PilihLokasiRuangan(
                                listRuangan: _roomList,
                                token: user.token,
                                selectedLocation: _selectedRoom,
                                onLocationSelected: (option) {
                                  setState(() {
                                    _selectedRoom = option;
                                    cartProvider.setIdRoom(option!);
                                  });
                                },
                              ),
                            ],
                          ),
                      ],
                      const SizedBox(height: 20),

                      // The summary of the order (either for the user or for the kasir)
                      RingkasanPembayaranCart(
                        isKasir: isKasirProviderActive,
                      ),
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
                final isKasirProviderActive = kasirProvider.cart.isNotEmpty;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PilihTipePembayaran(
                        isKasirActive: isKasirProviderActive,
                        tipePembayaran: _paymentType,
                        pilihTipePembayaran: _selectedPaymentMethod,
                        selectedPembayaran: (option2) {
                          setState(() {
                            _selectedPaymentMethod = option2;
                            cartProvider.setPaymentMethod(option2!);
                            kasirProvider.setMetodePembayaran(option2);
                            log(cartProvider.getTotal().toString());
                          });
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      BottomNavigationButton(
                        isLoading: cartProvider.isLoading,
                        color: AppColors.primaryColor,
                        onTap: () {
                          handleTransaction(
                            context,
                            kasirProvider,
                            cartProvider,
                            user,
                            _selectedRoom,
                          );
                        },
                      )
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }
}
