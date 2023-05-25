import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/views/home/history_page.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/home/profile_page.dart';

import '../../http/fetch_all_tenant.dart';
import '../../model/tenant_model.dart';

class NavbarHome extends StatefulWidget {
  final token;
  const NavbarHome({Key? key, required this.token} ) : super(key: key);

  @override
  State<NavbarHome> createState() => _NavbarHomeState();
}

class _NavbarHomeState extends State<NavbarHome> {

  int indexSekarang = 0;
  late Future<List<TenantModel>> futureTenant;
  String url = "http://masbrocanteen.me/api/tenant";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];

  @override
  void initState() {
    // TODO: implement initState'
    super.initState();
    futureTenant = fetchTenant(url, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    Widget halaman(){
      switch (indexSekarang) {
        case 0:
          return HomePage(token: widget.token,); // Contoh: Halaman Beranda
        case 1:
          return HistoryPage(); // Contoh: Halaman Pencarian
        case 2:
          return ProfilePage(); // Contoh: Halaman Profil
        default:
          return halaman(); // Jika indeks tidak valid, kembalikan widget kosong
      }
    }
    return Scaffold(
      backgroundColor: Colors.grey,
      body: halaman(),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedFontSize: 1,
        currentIndex: indexSekarang,
        onTap: (value) {
          print(value);
          setState(() {
            indexSekarang = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: indexSekarang == 0 ? Colors.red : Colors.grey,),
            label: ''
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.description, color: indexSekarang == 1 ? Colors.red : Colors.grey,),
              label: ''
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: indexSekarang == 2 ? Colors.red : Colors.grey,),
              label: ''
          ),
        ],
      ),
    );
  }
}
