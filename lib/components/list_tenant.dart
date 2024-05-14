import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testgetdata/common/format_currency.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/theme/deskripsi_theme.dart';
import 'package:testgetdata/theme/judul_font.dart';
import 'package:testgetdata/theme/sub_judul_theme.dart';
import 'package:testgetdata/views/menu_tenant.dart';

class ListTenant extends StatelessWidget {
  final url;
  final List<TenantModel> foundTenant;

  const ListTenant({
    super.key,
    required this.url,
    required this.foundTenant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount: foundTenant.length,
        itemBuilder: (context, index) {
          final range = FormatCurrency.intToStringCurrency(
            foundTenant[index].range ?? 0,
          );
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  print(url);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return MenuTenant(
                        url: '$url/${foundTenant[index].id}',
                      );
                    },
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.1,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        20,
                      ),
                    ),
                  ),
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 200, 200, 200),
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        NetworkImage(foundTenant[index].gambar),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foundTenant[index].namaTenant,
                                    style: Judul(),
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    height: 10,
                                  ),
                                  Text(
                                    foundTenant[index].namaKavling,
                                    style: SubJudul(),
                                  ),
                                  Text(
                                    "Mulai harga $range",
                                    style: Deskripsi(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          );
        },
      ),
    );
    ;
  }
}
