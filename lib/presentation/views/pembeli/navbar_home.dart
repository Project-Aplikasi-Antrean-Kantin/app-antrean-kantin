import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/fitur_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/widgets/switch_route.dart';
import 'package:testgetdata/core/theme/theme.dart';

class NavbarHome extends StatefulWidget {
  final int pageIndex;
  const NavbarHome({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<NavbarHome> createState() => _NavbarHomeState();
}

class _NavbarHomeState extends State<NavbarHome> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    List<FiturModel> listFitur = authProvider.user.menu;

    // Halaman yang baru dipilih bukan halaman kasir, maka bersihkan keranjang belanja
    void clearCartIfRequired(int newIndex) {
      KasirProvider kasirProvider =
          Provider.of<KasirProvider>(context, listen: false);
      FiturModel selectedFeature = listFitur[newIndex];
      if (selectedFeature.nama.toLowerCase() == "kasir") {
        return;
      }
      kasirProvider.clearCart();
    }

    String kapitalHurufDepan(String text) {
      if (text.isEmpty) return text;
      return text.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    List<BottomNavigationBarItem> _buildBottomNavigationBarItems(
        List<FiturModel> listFitur) {
      return listFitur.map((e) {
        return BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SvgPicture.network(
              e.ikon!,
              height: 20,
              colorFilter: ColorFilter.mode(
                unselectedIconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          activeIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SvgPicture.network(
              e.ikon!,
              height: 20,
              colorFilter: ColorFilter.mode(
                selectedIconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          label: kapitalHurufDepan(e.nama),
        );
      }).toList();
    }

    Widget _buildPage(FiturModel fitur) {
      return FeaturePage(
        url: fitur.url!,
        authProvider: authProvider,
      );
    }

    return Scaffold(
      body: _buildPage(listFitur[_currentIndex]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.2,
            color: Colors.grey,
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 9,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 9,
            ),
            unselectedFontSize: 12,
            unselectedItemColor: unselectedIconColor,
            selectedItemColor: selectedIconColor,
            currentIndex: _currentIndex,
            showUnselectedLabels: true,
            onTap: (index) {
              // Panggil fungsi clearCartIfRequired saat pengguna mengubah halaman
              clearCartIfRequired(index);
              setState(() {
                _currentIndex = index;
              });
            },
            items: _buildBottomNavigationBarItems(listFitur),
          ),
        ],
      ),
    );
  }
}

class FeaturePage extends StatelessWidget {
  final String url;
  final AuthProvider authProvider;

  const FeaturePage({Key? key, required this.url, required this.authProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getFeaturePage(url);
  }
}
