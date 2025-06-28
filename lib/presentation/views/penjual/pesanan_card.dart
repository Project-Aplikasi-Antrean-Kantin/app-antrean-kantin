import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class PesananCard extends StatefulWidget {
  final Pesanan pesanan;
  final OrderStatus status;
  final String token;

  const PesananCard({
    Key? key,
    required this.pesanan,
    required this.status,
    required this.token,
  }) : super(key: key);

  @override
  PesananCardState createState() => PesananCardState();
}

class PesananCardState extends State<PesananCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section - Pembeli & Nomor Pesanan
            _buildHeader(),

            const Divider(
              height: 30,
              color: AppColors.lineDividerColor,
              thickness: 0.3,
            ),

            // Rincian Pesanan Section
            Text(
              'Rincian Pesananmu',
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 14,
                fontWeight: semibold,
              ),
            ),
            const SizedBox(height: 12),

            // List Menu Items
            ...widget.pesanan.listTransaksiDetail.map((item) {
              return _buildMenuItem(item);
            }).toList(),

            // Summary Section
            _buildSummary(),

            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButton(context, widget.pesanan),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembeli',
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.pesanan.namaPembeli!,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'No. Pesanan',
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.containerColorGrey200,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'ORDER-0${widget.pesanan.id}',
                style: GoogleFonts.poppins(
                  color: AppColors.textColorGrey700,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(ListTransaksiDetail item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.jumlah}X',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Menu Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.namaMenu ?? 'Menu Item',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      FormatCurrency.intToStringCurrency(item.harga),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                // Catatan section
                const SizedBox(height: 8),
                if (item.catatan != null && item.catatan!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan: ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.catatan!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.amber[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Catatan: -',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final totalItemMenu = widget.pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);
    return Column(
      spacing: 10,
      children: [
        const Divider(
          height: 30,
          color: AppColors.lineDividerColor,
          thickness: 0.3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal ($totalItemMenu item)',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(widget.pesanan.subTotal),
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // tambahin tinggi

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(
                  widget.pesanan.total - widget.pesanan.ongkosKirim),
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Kode Pemesanan',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 12,
              fontWeight: medium,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.containerColorGrey200,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: Text(
              widget.pesanan.kodePemesanan ?? "",
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 12,
                fontWeight: bold,
              ),
            ),
          ),
        ])
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Pesanan pesanan) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    switch (widget.status) {
      case OrderStatus.pesananMasuk:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PrimaryButton(
                isEnabled: !_isLoading,
                elevation: 0,
                forgroundColor: AppColors.debugColor,
                borderColor: AppColors.debugColor,
                color: AppColors.containerColorWhite,
                height: screenSize.height * 0.05,
                borderRadius: 100,
                child: Text(
                  'Tolak',
                  style: GoogleFonts.poppins(
                    color: !_isLoading
                        ? AppColors.debugColor
                        : AppColors.containerColorGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final success =
                      await orderProvider.cancelOrder(widget.token, pesanan.id);
                  if (success) {
                    Fluttertoast.showToast(
                      msg: "Pesanan telah ditolak",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Gagal menolak pesanan",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                  if (mounted) {
                    // Check if the widget is still mounted
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: PrimaryButton(
                isLoading: _isLoading,
                elevation: 0,
                height: screenSize.height * 0.05,
                borderRadius: 100,
                child: Text(
                  'Terima',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final success = await orderProvider.updateOrder(
                      'pesanan_diproses', widget.token, pesanan.id, pesanan);

                  if (success) {
                    Fluttertoast.showToast(
                      msg: "Segera proses pesanan!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Gagal menerima pesanan",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                  if (mounted) {
                    // Check if the widget is still mounted
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ),
          ],
        );
      case OrderStatus.pesananDiproses:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrimaryButton(
              isLoading: _isLoading,
              elevation: 0,
              width: screenSize.width * 0.5,
              height: screenSize.height * 0.05,
              borderRadius: 10,
              color: AppColors.primaryColor,
              child: Text(
                'Pesanan Siap',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                final status =
                    pesanan.isAntar == 1 ? 'siap_diantar' : 'siap_diambil';
                final success = await orderProvider.updateOrder(
                    status, widget.token, pesanan.id, pesanan);

                if (success) {
                  Fluttertoast.showToast(
                    msg: "Pesanan Siap",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Gagal memperbarui pesanan",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
                if (mounted) {
                  // Check if the widget is still mounted
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/core/theme/colors_theme.dart';
// import 'package:testgetdata/core/theme/text_theme.dart';
// import 'package:testgetdata/data/model/pesanan_model.dart';
// import 'package:testgetdata/presentation/views/common/format_currency.dart';
// import 'package:testgetdata/presentation/views/penjual/order_status.dart';
// import 'package:testgetdata/presentation/provider/order_provider.dart';
// import 'package:testgetdata/presentation/widgets/primary_button.dart';

// class PesananCard extends StatefulWidget {
//   final Pesanan pesanan;
//   final OrderStatus status;
//   final String token;

//   const PesananCard({
//     Key? key,
//     required this.pesanan,
//     required this.status,
//     required this.token,
//   }) : super(key: key);

//   @override
//   PesananCardState createState() => PesananCardState();
// }

// class PesananCardState extends State<PesananCard> with TickerProviderStateMixin {
//   bool _isLoading = false;
//   bool _isExpanded = false; // State untuk mengontrol expand/collapse
//   late AnimationController _animationController;
//   late Animation<double> _expandAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggleExpansion() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalItemMenu = widget.pesanan.listTransaksiDetail
//         .map((item) => item.jumlah)
//         .fold(0, (prev, jumlah) => prev + jumlah);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Section - Pembeli & Nomor Pesanan
//             _buildHeader(),

//             const Divider(
//               height: 30,
//               color: AppColors.lineDividerColor,
//               thickness: 0.3,
//             ),

//             // Rincian Pesanan Section dengan tombol expand/collapse
//             _buildExpandableHeader(totalItemMenu),

//             // List Menu Items yang bisa di-expand/collapse
//             SizeTransition(
//               sizeFactor: _expandAnimation,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   ...widget.pesanan.listTransaksiDetail.map((item) {
//                     return _buildMenuItem(item);
//                   }).toList(),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Summary Section
//             _buildSummary(totalItemMenu),

//             const SizedBox(height: 20),

//             // Action Buttons
//             _buildActionButton(context, widget.pesanan),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpandableHeader(int totalItemMenu) {
//     return GestureDetector(
//       onTap: _toggleExpansion,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Rincian Pesanan',
//                   style: GoogleFonts.poppins(
//                     color: AppColors.textColorBlack,
//                     fontSize: 14,
//                     fontWeight: semibold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$totalItemMenu item pesanan',
//                   style: GoogleFonts.poppins(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Text(
//                   _isExpanded ? 'Tutup' : 'Lihat Detail',
//                   style: GoogleFonts.poppins(
//                     color: AppColors.primaryColor,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 AnimatedRotation(
//                   turns: _isExpanded ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 300),
//                   child: Icon(
//                     Icons.keyboard_arrow_down,
//                     color: AppColors.primaryColor,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Pembeli',
//               style: GoogleFonts.poppins(
//                 color: Colors.grey[500],
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               widget.pesanan.namaPembeli!,
//               style: GoogleFonts.poppins(
//                 color: Colors.black87,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               'No. Pesanan',
//               style: GoogleFonts.poppins(
//                 color: Colors.grey[500],
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//               decoration: BoxDecoration(
//                 color: AppColors.containerColorGrey200,
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: Text(
//                 'ORDER-0${widget.pesanan.id}',
//                 style: GoogleFonts.poppins(
//                   color: AppColors.textColorGrey700,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMenuItem(dynamic item) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Product Image Placeholder
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 '${item.jumlah}X',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Menu Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         item.namaMenu ?? 'Menu Item',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       FormatCurrency.intToStringCurrency(
//                           (item.harga ?? 0) * (item.jumlah ?? 1)),
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Catatan section
//                 const SizedBox(height: 8),
//                 if (item.catatan != null && item.catatan!.isNotEmpty)
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.amber[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.amber[200]!),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Catatan: ',
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.amber[800],
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             item.catatan!,
//                             style: GoogleFonts.poppins(
//                               fontSize: 12,
//                               color: Colors.amber[800],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   Text(
//                     'Catatan: -',
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummary(int totalItemMenu) {
//     return Column(
//       children: [
//         const Divider(
//           height: 30,
//           color: AppColors.lineDividerColor,
//           thickness: 0.3,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Subtotal ($totalItemMenu item)',
//               style: GoogleFonts.poppins(
//                 color: Colors.black87,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Text(
//               FormatCurrency.intToStringCurrency(widget.pesanan.subTotal),
//               style: GoogleFonts.poppins(
//                 color: Colors.black87,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Total',
//               style: GoogleFonts.poppins(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               FormatCurrency.intToStringCurrency(
//                   widget.pesanan.total - widget.pesanan.ongkosKirim),
//               style: GoogleFonts.poppins(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton(BuildContext context, Pesanan pesanan) {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     final screenSize = MediaQuery.of(context).size;

//     switch (widget.status) {
//       case OrderStatus.pesananMasuk:
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: PrimaryButton(
//                 isEnabled: !_isLoading,
//                 elevation: 0,
//                 forgroundColor: AppColors.debugColor,
//                 borderColor: AppColors.debugColor,
//                 color: AppColors.containerColorWhite,
//                 height: screenSize.height * 0.05,
//                 borderRadius: 100,
//                 child: Text(
//                   'Tolak',
//                   style: GoogleFonts.poppins(
//                     color: !_isLoading
//                         ? AppColors.debugColor
//                         : AppColors.containerColorGrey,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onPressed: () async {
//                   setState(() {
//                     _isLoading = true;
//                   });
//                   final success =
//                       await orderProvider.cancelOrder(widget.token, pesanan.id);
//                   if (success) {
//                     Fluttertoast.showToast(
//                       msg: "Pesanan telah ditolak",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.TOP,
//                       backgroundColor: Colors.red,
//                       textColor: Colors.white,
//                       fontSize: 16.0,
//                     );
//                   } else {
//                     Fluttertoast.showToast(
//                       msg: "Gagal menolak pesanan",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.TOP,
//                       backgroundColor: Colors.red,
//                       textColor: Colors.white,
//                       fontSize: 16.0,
//                     );
//                   }
//                   if (mounted) {
//                     setState(() {
//                       _isLoading = false;
//                     });
//                   }
//                 },
//               ),
//             ),
//             SizedBox(width: screenSize.width * 0.03),
//             Expanded(
//               child: PrimaryButton(
//                 isLoading: _isLoading,
//                 elevation: 0,
//                 height: screenSize.height * 0.05,
//                 borderRadius: 100,
//                 child: Text(
//                   'Terima',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 onPressed: () async {
//                   setState(() {
//                     _isLoading = true;
//                   });
//                   final success = await orderProvider.updateOrder(
//                       'pesanan_diproses', widget.token, pesanan.id, pesanan);

//                   if (success) {
//                     Fluttertoast.showToast(
//                       msg: "Segera proses pesanan!",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.TOP,
//                       backgroundColor: Colors.grey,
//                       textColor: Colors.white,
//                       fontSize: 16.0,
//                     );
//                   } else {
//                     Fluttertoast.showToast(
//                       msg: "Gagal menerima pesanan",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.TOP,
//                       backgroundColor: Colors.red,
//                       textColor: Colors.white,
//                       fontSize: 16.0,
//                     );
//                   }
//                   if (mounted) {
//                     setState(() {
//                       _isLoading = false;
//                     });
//                   }
//                 },
//               ),
//             ),
//           ],
//         );
//       case OrderStatus.pesananDiproses:
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             PrimaryButton(
//               isLoading: _isLoading,
//               elevation: 0,
//               width: screenSize.width * 0.5,
//               height: screenSize.height * 0.05,
//               borderRadius: 100,
//               color: AppColors.primaryColor,
//               child: Text(
//                 'Pesanan Siap',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               onPressed: () async {
//                 setState(() {
//                   _isLoading = true;
//                 });
//                 final status =
//                     pesanan.isAntar == 1 ? 'siap_diantar' : 'selesai';
//                 final success = await orderProvider.updateOrder(
//                     status, widget.token, pesanan.id, pesanan);

//                 if (success) {
//                   Fluttertoast.showToast(
//                     msg: "Pesanan Siap",
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.TOP,
//                     backgroundColor: Colors.grey,
//                     textColor: Colors.white,
//                     fontSize: 16.0,
//                   );
//                 } else {
//                   Fluttertoast.showToast(
//                     msg: "Gagal memperbarui pesanan",
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.TOP,
//                     backgroundColor: Colors.red,
//                     textColor: Colors.white,
//                     fontSize: 16.0,
//                   );
//                 }
//                 if (mounted) {
//                   setState(() {
//                     _isLoading = false;
//                   });
//                 }
//               },
//             ),
//           ],
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
