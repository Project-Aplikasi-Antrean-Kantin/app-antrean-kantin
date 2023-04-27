import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:testgetdata/component/katalog.dart';
import 'package:testgetdata/controller/scroll_controller_positionerd.dart';
import 'package:testgetdata/model/cart_model.dart';
import 'package:testgetdata/theme/judul_font.dart';

class ListFoodsByCategory extends StatelessWidget {
  final Map<String, List<dynamic>> listMenu;
  final namaTenant;

  const ListFoodsByCategory({required this.listMenu, required this.namaTenant});

  @override
  Widget build(BuildContext context) {
    final keysMenu = listMenu.keys;
    print(listMenu['Makanan']![0]);
    return Expanded(
      child: ScrollablePositionedList.builder(
        itemScrollController: ScrollPositionedControl.itemController,
        shrinkWrap: true,
        itemCount: keysMenu.length,
        itemBuilder: (BuildContext context, int index) {
          final makanan = listMenu[keysMenu.elementAt(index).toString()]!;
          return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(keysMenu.elementAt(index).toString()),
                  for (int i = 0; i < listMenu[keysMenu.elementAt(index).toString()]!.length; i++)
                    katalog(
                      makanan: makanan[i],
                      namaTenant: namaTenant,
                    )
                ],
              ));
        },
      ),
    );
  }
}
