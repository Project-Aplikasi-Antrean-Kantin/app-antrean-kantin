import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/data/provider/katalog_menu_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/penjual/edit_menu.dart';

class KatalogMenuTile extends StatelessWidget {
  final TenantFoods item;
  final void Function(bool) onChanged;

  const KatalogMenuTile({
    super.key,
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              image: DecorationImage(
                image: NetworkImage("${MasbroConstants.baseUrl}${item.gambar}"),
                fit: BoxFit.cover,
              ),
            ),
            height: 75,
            width: 75,
            margin: const EdgeInsets.only(right: 15),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama ?? item.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  FormatCurrency.intToStringCurrency(item.harga),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    print('tile gesture detector jalan');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMenuPage(
                          tenantFoods: item,
                        ),
                      ),
                    ).then((value) {
                      print("runtime type : " + value.runtimeType.toString());
                      print('value $value');
                      if ((value as bool?) == true) {
                        context
                            .read<KatalogMenuProvider>()
                            .fetchData(context.read<AuthProvider>().user.token);
                      }
                    });
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF326CA1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Switch(
              activeColor: Color(0xFF233A6C),
              value: item.isReady == 1,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
