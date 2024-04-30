import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/navbar_home.dart';

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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.redAccent,
        toolbarHeight: 320,
        scrolledUnderElevation: 0,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(35),
        //     bottomRight: Radius.circular(35),
        //   ),
        // ),
        flexibleSpace: FlexibleSpaceBar(
          title: Container(
            padding: const EdgeInsets.only(
              top: 60,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Text(
                    'Profile',
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
                      image: AssetImage(
                        "assets/images/dummy.jpeg",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 160,
                  width: 160,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Column(
                    children: [
                      Text(
                        user.nama,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
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
          centerTitle: true,
        ),
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     width: 1,
        //   ),
        // ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            user.permission.contains('read katalog')
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Text(
                          'Penjual',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/katalog_menu');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 0.2,
                                color: Colors.grey[900]!,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(
                                  Icons.restaurant,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Tambah Menu',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              const Icon(
                                Icons.arrow_right,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigator.of(context).pushNamed('/riwayat1');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 0.2,
                                color: Colors.grey[900]!,
                              ),
                              bottom: BorderSide(
                                width: 0.2,
                                color: Colors.grey[900]!,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(
                                  Icons.storefront,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Profil Tenant',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              const Icon(
                                Icons.arrow_right,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(
                    height: 0,
                  ),
            Container(
              padding: const EdgeInsets.only(
                bottom: 10,
                top: 20,
              ),
              child: Text(
                'Pengaturan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 0.2,
                      color: Colors.grey[900]!,
                    ),
                    bottom: BorderSide(
                      width: 0.2,
                      color: Colors.grey[900]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Akun dan Keamanan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    const Icon(
                      Icons.arrow_right,
                      size: 24.0,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: handleLogout,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.2,
                      color: Colors.grey[900]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.logout,
                        size: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    const Icon(
                      Icons.arrow_right,
                      size: 24.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavbarHome(
        pageIndex: user.menu.indexWhere((element) => element.url == '/profile'),
      ),
    );
  }
}
