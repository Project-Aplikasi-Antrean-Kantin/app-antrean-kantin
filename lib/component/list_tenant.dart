import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/theme/deskripsi_theme.dart';
import 'package:testgetdata/theme/judul_font.dart';
import 'package:testgetdata/views/list_makanan.dart';
import 'package:testgetdata/views/list_tenant.dart';

class ListTenantBaru extends StatelessWidget {
  final url;
  final foundTenant;
  const ListTenantBaru({required this.url, required this.foundTenant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount: foundTenant.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ListTenant(
                  url: '${url}/${foundTenant[index].id}',
                );
              }));
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    ClipRRect(
                      child: Image(
                        image: NetworkImage(foundTenant[index].gambar),
                        height: 111,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foundTenant[index].name,
                            style: Judul(),
                          ),
                          Text(
                            foundTenant[index].subname,
                            // style: SubJudul(),
                          ),
                          Divider(
                            color: Colors.red,
                            height: 10,
                          ),
                          Text(
                            "Start From",
                            style: Deskripsi(),
                          ),
                          Text(
                            "Data",
                            style: Deskripsi(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    ;
  }
}
