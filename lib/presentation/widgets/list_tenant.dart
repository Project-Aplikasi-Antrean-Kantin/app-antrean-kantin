// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:testgetdata/core/theme/colors_theme.dart';
// import 'package:testgetdata/data/model/tenant_model.dart';
// import 'package:testgetdata/presentation/views/common/format_currency.dart';
// import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
// import 'package:testgetdata/core/theme/text_theme.dart';
// import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
// import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

// class ListTenant extends StatelessWidget {
//   // ignore: prefer_typing_uninitialized_variables
//   final url;
//   final List<TenantModel> foundTenant;
//   final void Function(Widget page) onNavigate;

//   const ListTenant({
//     super.key,
//     required this.url,
//     required this.foundTenant,
//     required this.onNavigate,
//   });

//   Route MenuTenantPage(index) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => MenuTenant(
//         url: '$url/${foundTenant[index].id}',
//       ),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset(0.0, 0.0);
//         const curve = Curves.easeInOut;

//         var tween =
//             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);

//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     );
//   }

//   bool isTenantOpen(String jamBuka, String jamTutup) {
//     try {
//       // Normalisasi format waktu
//       String normalizeTime(String time) {
//         time = time.replaceAll('.', ':').trim();
//         if (time.contains(':')) {
//           final parts = time.split(':');
//           if (parts.length > 2) {
//             return '${parts[0]}:${parts[1]}';
//           }
//         }
//         return time;
//       }

//       jamBuka = normalizeTime(jamBuka);
//       jamTutup = normalizeTime(jamTutup);

//       final now = DateTime.now();

//       final bukaParts = jamBuka.split(':');
//       final tutupParts = jamTutup.split(':');

//       if (bukaParts.length != 2 || tutupParts.length != 2) {
//         debugPrint('Invalid time format: jamBuka=$jamBuka, jamTutup=$jamTutup');
//         return false;
//       }

//       final bukaTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         int.parse(bukaParts[0]),
//         int.parse(bukaParts[1]),
//       );

//       final tutupTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         int.parse(tutupParts[0]),
//         int.parse(tutupParts[1]),
//       );

//       final isOpen = now.isAfter(bukaTime) &&
//           (now.isBefore(tutupTime) || now.isAtSameMomentAs(tutupTime));
//       debugPrint(
//           'Tenant check: now=$now, bukaTime=$bukaTime, tutupTime=$tutupTime, isOpen=$isOpen');
//       return isOpen;
//     } catch (e) {
//       debugPrint(
//           'Error parsing time: jamBuka=$jamBuka, jamTutup=$jamTutup, error=$e');
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         padding: const EdgeInsets.only(bottom: 1),
//         physics: const ScrollPhysics(),
//         shrinkWrap: true,
//         itemCount: foundTenant.length,
//         itemBuilder: (context, index) {
//           final tenant = foundTenant[index];
//           final isOpen = isTenantOpen(tenant.jamBuka, tenant.jamTutup);

//           return GestureDetector(
//             onTap: () {
//               log(tenant.isOnline.toString());
//               if (isOpen) {
//                 debugPrint(url);
//                 onNavigate(MenuTenant(url: '$url/${tenant.id}'));
//               } else if (tenant.isOnline == true) {
//                 debugPrint(url);
//                 onNavigate(MenuTenant(url: '$url/${tenant.id}'));
//               } else {
//                 showDialog(
//                   context: context,
//                   builder: (context) {
//                     return CustomAlertDialog(
//                       title: 'Tenant Tidak Tersedia',
//                       message:
//                           'Tenant ini sedang tutup. Mungkin datanya belum diperbarui. Silakan coba lagi nanti.',
//                       textButtonOk: 'Oke',
//                       showCancelButton: false,
//                       onOkPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     );
//                   },
//                 );
//               }
//             },
//             child: Container(
//               margin: const EdgeInsets.only(right: 15, left: 15, bottom: 10),
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.all(Radius.circular(10)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 2,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//                 color: isOpen
//                     ? AppColors.containerColorWhite
//                     : Colors.grey.shade300, // abu-abu jika tutup
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     // child: ClipRRect(
//                     //   borderRadius: const BorderRadius.only(
//                     //     topRight: Radius.circular(10),
//                     //     topLeft: Radius.circular(10),
//                     //   ),
//                     //   child: Stack(
//                     //     children: [
//                     //       const ShimmerLoadingWidget(
//                     //         shimmerContainerImage: true,
//                     //         padding: EdgeInsets.zero,
//                     //         heightContainerImage: 200,
//                     //         widhtContainerImage: double.infinity,
//                     //       ),
//                     //       foundTenant[index].gambar.isNotEmpty
//                     //           ? Image.network(
//                     //               foundTenant[index].gambar,
//                     //               fit: BoxFit.cover,
//                     //               width: double.infinity,
//                     //               height: 200,
//                     //               loadingBuilder:
//                     //                   (context, child, loadingProgress) {
//                     //                 if (loadingProgress == null) return child;
//                     //                 return const ShimmerLoadingWidget(
//                     //                   shimmerContainerImage: true,
//                     //                   padding: EdgeInsets.zero,
//                     //                   heightContainerImage: 200,
//                     //                   widhtContainerImage: double.infinity,
//                     //                 );
//                     //               },
//                     //               errorBuilder: (context, error, stackTrace) {
//                     //                 return Image.asset(
//                     //                   'assets/images/dummy.jpeg',
//                     //                   fit: BoxFit.cover,
//                     //                   width: double.infinity,
//                     //                   height: 200,
//                     //                 );
//                     //               },
//                     //             )
//                     //           : Image.asset(
//                     //               'assets/images/dummy.jpeg',
//                     //               fit: BoxFit.cover,
//                     //               width: double.infinity,
//                     //               height: 200,
//                     //             ),
//                     //     ],
//                     //   ),
//                     // ),
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topRight: Radius.circular(10),
//                         topLeft: Radius.circular(10),
//                       ),
//                       child: ColorFiltered(
//                         colorFilter: isOpen
//                             ? const ColorFilter.mode(
//                                 Colors.transparent, BlendMode.multiply)
//                             : const ColorFilter.matrix(<double>[
//                                 0.2126,
//                                 0.7152,
//                                 0.0722,
//                                 0,
//                                 0,
//                                 0.2126,
//                                 0.7152,
//                                 0.0722,
//                                 0,
//                                 0,
//                                 0.2126,
//                                 0.7152,
//                                 0.0722,
//                                 0,
//                                 0,
//                                 0,
//                                 0,
//                                 0,
//                                 1,
//                                 0,
//                               ]),
//                         child: Stack(
//                           children: [
//                             const ShimmerLoadingWidget(
//                               shimmerContainerImage: true,
//                               padding: EdgeInsets.zero,
//                               heightContainerImage: 200,
//                               widhtContainerImage: double.infinity,
//                             ),
//                             tenant.gambar.isNotEmpty
//                                 ? Image.network(
//                                     tenant.gambar,
//                                     fit: BoxFit.cover,
//                                     width: double.infinity,
//                                     height: 200,
//                                     loadingBuilder:
//                                         (context, child, loadingProgress) {
//                                       if (loadingProgress == null) return child;
//                                       return const ShimmerLoadingWidget(
//                                         shimmerContainerImage: true,
//                                         padding: EdgeInsets.zero,
//                                         heightContainerImage: 200,
//                                         widhtContainerImage: double.infinity,
//                                       );
//                                     },
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Image.asset(
//                                         'assets/images/dummy.jpeg',
//                                         fit: BoxFit.cover,
//                                         width: double.infinity,
//                                         height: 200,
//                                       );
//                                     },
//                                   )
//                                 : Image.asset(
//                                     'assets/images/dummy.jpeg',
//                                     fit: BoxFit.cover,
//                                     width: double.infinity,
//                                     height: 200,
//                                   ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     foundTenant[index].namaTenant,
//                                     // style: Judul(),
//                                     style: GoogleFonts.poppins(
//                                       color: AppColors.textColorBlack,
//                                       fontSize: 16,
//                                       fontWeight: semibold,
//                                     ),
//                                   ),
//                                   SizedBox(width: 5),
//                                   isOpen
//                                       ? SizedBox()
//                                       : Text(
//                                           "Tutup",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 12,
//                                             color: Colors.red,
//                                             fontWeight: medium,
//                                           ),
//                                         ),
//                                 ],
//                               ),
//                               Text(
//                                 "Aneka makanan mulai dari " +
//                                     FormatCurrency.intToStringCurrency(
//                                         foundTenant[index].range!),
//                                 style: GoogleFonts.poppins(
//                                   color: AppColors.textColorBlack,
//                                   fontSize: 12,
//                                   fontWeight: regular,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         // Nomor Kavling
//                         Container(
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               width: 0.3,
//                               color: AppColors.containerColorGrey,
//                             ),
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(25),
//                             ),
//                           ),
//                           height: 50,
//                           width: 50,
//                           child: Center(
//                             child: Text(
//                               foundTenant[index].namaKavling,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 color: AppColors.textColorBlack,
//                                 fontWeight: bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class ListTenant extends StatelessWidget {
  final url;
  final List<TenantModel> foundTenant;
  final void Function(Widget page) onNavigate;

  const ListTenant({
    super.key,
    required this.url,
    required this.foundTenant,
    required this.onNavigate,
  });

  Route MenuTenantPage(index) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MenuTenant(
        url: '$url/${foundTenant[index].id}',
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // bool isTenantOpen(String jamBuka, String jamTutup, bool isOnline) {
  //   try {
  //     // Normalisasi format waktu
  //     String normalizeTime(String time) {
  //       time = time.replaceAll('.', ':').trim();
  //       if (time.contains(':')) {
  //         final parts = time.split(':');
  //         if (parts.length > 2) {
  //           return '${parts[0]}:${parts[1]}';
  //         }
  //       }
  //       return time;
  //     }

  //     jamBuka = normalizeTime(jamBuka);
  //     jamTutup = normalizeTime(jamTutup);

  //     final now = DateTime.now();

  //     final bukaParts = jamBuka.split(':');
  //     final tutupParts = jamTutup.split(':');

  //     if (bukaParts.length != 2 || tutupParts.length != 2) {
  //       debugPrint('Invalid time format: jamBuka=$jamBuka, jamTutup=$jamTutup');
  //       return false;
  //     }

  //     final bukaTime = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       int.parse(bukaParts[0]),
  //       int.parse(bukaParts[1]),
  //     );

  //     final tutupTime = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       int.parse(tutupParts[0]),
  //       int.parse(tutupParts[1]),
  //     );

  //     // Logika:
  //     // 1. Jika waktu sudah lewat jamTutup, tenant tutup
  //     if (now.isAfter(tutupTime)) {
  //       debugPrint(
  //           'Tenant closed: now=$now is after tutupTime=$tutupTime, isOnline=$isOnline');
  //       return false;
  //     }
  //     // 2. Jika waktu belum mencapai jamBuka atau dalam jam operasional,
  //     // status bergantung pada isOnline
  //     debugPrint(
  //         'Tenant check: now=$now, bukaTime=$bukaTime, tutupTime=$tutupTime, isOnline=$isOnline, isOpen=$isOnline');
  //     return isOnline;
  //   } catch (e) {
  //     debugPrint(
  //         'Error parsing time: jamBuka=$jamBuka, jamTutup=$jamTutup, isOnline=$isOnline, error=$e');
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(bottom: 1),
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount: foundTenant.length,
        itemBuilder: (context, index) {
          final tenant = foundTenant[index];
          // final isOpen =
          //     isTenantOpen(tenant.jamBuka, tenant.jamTutup, tenant.isOnline);

          return GestureDetector(
            onTap: () {
              // log('Tenant: ${tenant.namaTenant}, isOnline: ${tenant.isOnline}, isOpen: $isOpen');
              if (tenant.isOnline == true) {
                debugPrint(url);
                onNavigate(MenuTenant(url: '$url/${tenant.id}'));
                log(tenant.isOnline.toString());
              } else {
                log(tenant.isOnline.toString());
                showDialog(
                  context: context,
                  builder: (context) {
                    return CustomAlertDialog(
                      title: 'Tenant Tidak Tersedia',
                      message:
                          'Tenant ini sedang tutup. Mungkin tenant sedang offline atau di luar jam operasional. Silakan coba lagi nanti.',
                      textButtonOk: 'Oke',
                      showCancelButton: false,
                      onOkPressed: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15, left: 15, bottom: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
                color: tenant.isOnline == true
                    ? AppColors.containerColorWhite
                    : Colors.grey.shade300, // abu-abu jika tutup
              ),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      child: ColorFiltered(
                        colorFilter: tenant.isOnline == true
                            ? const ColorFilter.mode(
                                Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                        child: Stack(
                          children: [
                            const ShimmerLoadingWidget(
                              shimmerContainerImage: true,
                              padding: EdgeInsets.zero,
                              heightContainerImage: 200,
                              widhtContainerImage: double.infinity,
                            ),
                            tenant.gambar.isNotEmpty
                                ? Image.network(
                                    tenant.gambar,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const ShimmerLoadingWidget(
                                        shimmerContainerImage: true,
                                        padding: EdgeInsets.zero,
                                        heightContainerImage: 200,
                                        widhtContainerImage: double.infinity,
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/dummy.jpeg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/dummy.jpeg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    foundTenant[index].namaTenant,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textColorBlack,
                                      fontSize: 16,
                                      fontWeight: semibold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  tenant.isOnline == true
                                      ? const SizedBox()
                                      : Text(
                                          "Tutup",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: medium,
                                          ),
                                        ),
                                ],
                              ),
                              Text(
                                "Aneka makanan mulai dari " +
                                    FormatCurrency.intToStringCurrency(
                                        foundTenant[index].range ?? 0),
                                style: GoogleFonts.poppins(
                                  color: AppColors.textColorBlack,
                                  fontSize: 12,
                                  fontWeight: regular,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.3,
                              color: AppColors.containerColorGrey,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          height: 50,
                          width: 50,
                          child: Center(
                            child: Text(
                              foundTenant[index].namaKavling,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textColorBlack,
                                fontWeight: bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
