import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/controller/scroll_controller_positionerd.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/theme/judul_font.dart';

class JudulTenant extends StatelessWidget {
  final String judul;
  final category;

  const JudulTenant({
    required this.judul,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: Judul(),
          ),
          Row(
            children: [
              for (int i = 0; i < category.length; i++)
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Judul(),
                  ),
                  onPressed: () {
                    ScrollPositionedControl.itemController
                        .scrollTo(index: i, duration: Duration(seconds: 1));
                  },
                  child: Text(category[i]),
                ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
