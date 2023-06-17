import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/views/home/navbar_home.dart';

class HistoryPage extends StatefulWidget {
  static const int historyIndex = 1;
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
          child: Text("Coming Soon"),
        ),
        bottomNavigationBar: NavbarHome(pageIndex: HistoryPage.historyIndex,));
  }
}
