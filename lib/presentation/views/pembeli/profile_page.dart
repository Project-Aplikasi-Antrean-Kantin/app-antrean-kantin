import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/views/pembeli/edit_profil.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    handleLogout() async {
      await authProvider.logout(user.token);
      Navigator.pushReplacementNamed(context, '/');
    }

    void handleRouteKatalogMenuPage() {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              KatalogMenu(),
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
        ),
      );
    }

    // void handleRouteEditProfil() {
    //   Navigator.of(context).push(
    //     PageRouteBuilder(
    //       pageBuilder: (context, animation, secondaryAnimation) => EditProfil(
    //         userProfil: user,
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
    //     ),
    //   );
    // }

    void showTenantStatusBottomSheet(BuildContext context) {
      bool?
          selectedStatus; // null = belum pilih, true = online, false = offline

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubah Status Tenant',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: AppColors.textColorBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // === ONLINE OPTION ===
                    GestureDetector(
                      onTap: () {
                        setModalState(() => selectedStatus = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedStatus == true
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedStatus == true
                                ? AppColors.primaryColor
                                : Colors.grey,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Online',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textColorBlack,
                                    fontWeight: semibold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Pengguna bisa langsung memesan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textColorBlack,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              selectedStatus == true
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selectedStatus == true
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // === OFFLINE OPTION ===
                    GestureDetector(
                      onTap: () {
                        setModalState(() => selectedStatus = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedStatus == false
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedStatus == false
                                ? AppColors.primaryColor
                                : Colors.grey,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offline',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textColorBlack,
                                    fontWeight: semibold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Pengguna belum bisa memesan dari tokomu',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textColorBlack,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              selectedStatus == false
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selectedStatus == false
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // === Submit Button ===
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedStatus != null
                            ? () async {
                                await authProvider.updateTenantStatus(
                                    user.token, selectedStatus!);
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedStatus != null
                              ? AppColors.primaryColor
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Minimal AppBar to maintain status bar transparency
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section (moved from AppBar)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Akun Saya',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/dummy.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 160,
                    width: 160,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      children: [
                        Text(
                          capitalizeFirstLetter(user.nama),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu section
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  user.permission.contains('read katalog')
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Penjual',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            // ProfileMenuItem(
                            //   icon: Icons.storefront_outlined,
                            //   title: 'Edit Profil Tenant',
                            //   onTap: () {
                            //     // handleRouteKatalogMenuPage();
                            //   },
                            // ),
                            ProfileMenuItem(
                              icon: Icons.restaurant,
                              title: 'Katalog Menu',
                              onTap: () {
                                handleRouteKatalogMenuPage();
                              },
                            ),
                            // ProfileMenuItem(
                            //   icon: Icons.restaurant,
                            //   title: 'log',
                            //   onTap: () {
                            //     // handleRouteKatalogMenuPage();
                            //     log(user.isOnline.toString());
                            //     log(authProvider.user.isOnline.toString());
                            //   },
                            // ),
                            ProfileMenuItem(
                              // status: authProvider.user.isOnline,
                              icon: Icons.radio_button_on,
                              // iconColor: authProvider.user.isOnline!
                              //     ? Colors.green
                              //     : Colors.red,
                              title: 'Status Tenant',
                              onTap: () {
                                // handleRouteKatalogMenuPage();
                                showTenantStatusBottomSheet(context);
                              },
                            ),
                          ],
                        )
                      : const SizedBox(height: 0),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10, top: 20),
                    child: Text(
                      'Pengaturan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // ProfileMenuItem(
                  //   icon: Icons.account_circle_outlined,
                  //   title: 'Edit Profil',
                  //   onTap: () {
                  //     handleRouteEditProfil();
                  //   },
                  // ),
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    showIconArrow: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            title: "Konfirmasi Keluar",
                            message: "Apakah Anda yakin ingin keluar?",
                            showCancelButton: true,
                            onOkPressed: () {
                              handleLogout();
                              Navigator.of(context).pop();
                            },
                            onCancelPressed: () {
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
