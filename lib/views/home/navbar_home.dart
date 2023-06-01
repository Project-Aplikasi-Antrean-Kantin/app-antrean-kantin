import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/views/home/history_page.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/home/profile_page.dart';

import '../../http/fetch_all_tenant.dart';
import '../../model/tenant_model.dart';

class NavbarHome extends StatefulWidget {
  final int pageIndex;
  const NavbarHome({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<NavbarHome> createState() => _NavbarHomeState();
}

class _NavbarHomeState extends State<NavbarHome> {
  late Future<List<TenantModel>> futureTenant;
  String url = "http://masbrocanteen.me/api/tenant";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];

  @override
  void initState() {
    // TODO: implement initState'
    super.initState();
    futureTenant = fetchTenant(url);
  }

  @override
  Widget build(BuildContext context) {
    Widget? halaman(int selectedIndex) {
      if (selectedIndex == widget.pageIndex) return null;
      switch (selectedIndex) {
        case HomePage.homeIndex:
          return HomePage(); // Contoh: Halaman Beranda
        case HistoryPage.historyIndex:
          return HistoryPage(); // Contoh: Halaman Pencarian
        case ProfilePage.profileIndex:
          return ProfilePage(); // Contoh: Halaman Profil// Jika indeks tidak valid, kembalikan widget kosong
        default:
          return null;
      }
    }

    return BottomNavigationBar(
      elevation: 0,
      selectedFontSize: 1,
      currentIndex: widget.pageIndex,
      onTap: (value) {
        print(value);
        setState(() {
          Widget? nextWidget = halaman(value);
          if (nextWidget != null)
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => nextWidget!));
        });
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: widget.pageIndex == 0 ? Colors.red : Colors.grey,
            ),
            label: ''),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.description,
              color: widget.pageIndex == 1 ? Colors.red : Colors.grey,
            ),
            label: ''),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: widget.pageIndex == 2 ? Colors.red : Colors.grey,
            ),
            label: ''),
      ],
    );
  }
}
