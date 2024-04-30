import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/fitur_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';

class NavbarHome extends StatefulWidget {
  final int pageIndex;
  const NavbarHome({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<NavbarHome> createState() => _NavbarHomeState();
}

class _NavbarHomeState extends State<NavbarHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    List<FiturModel> listFitur = authProvider.user.menu;

    List<BottomNavigationBarItem> fiturNavigation(List<FiturModel> listFitur) {
      final fiturMap = listFitur.map((e) {
        return BottomNavigationBarItem(
            icon: const Icon(
              Icons.home,
            ),
            label: e.nama);
      }).toList();
      return fiturMap;
    }

    return BottomNavigationBar(
      elevation: 0,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.redAccent,
      currentIndex: widget.pageIndex,
      showUnselectedLabels: true,
      onTap: (value) {
        final fitur = listFitur[value];
        print(fitur.url);
        Navigator.pushReplacementNamed(context, fitur.url!);
      },
      items: listFitur.map((e) {
        return BottomNavigationBarItem(
          // icon: const Icon(
          //   IconData(
          //     0xe88a,
          //     fontFamily: 'MaterialIcons',
          //   ),
          // ),
          icon: SvgPicture.network(
            e.ikon!,
            height: 20,
          ),
          activeIcon: SvgPicture.network(
            e.ikon!,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.redAccent,
              BlendMode.srcIn,
            ),
          ),
          label: e.nama,
        );
      }).toList(),
    );
  }
}
