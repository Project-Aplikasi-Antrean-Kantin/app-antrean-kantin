import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/home/widgets/menu_tenant.dart';
import 'package:testgetdata/views/theme.dart';

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
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.top,
      ),
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: foundTenant.length,
      itemBuilder: (context, index) {
        final range = FormatCurrency.intToStringCurrency(
          foundTenant[index].range ?? 0,
        );
        // return Text('data');
        return GestureDetector(
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
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   border: Border.all(
            //     width: 0.1,
            //   ),
            // borderRadius: const BorderRadius.all(
            //   Radius.circular(
            //     20,
            //   ),
            // ),
            // ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 1.0, // Lebar border
                ),
                top: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 0.2, // Lebar border
                ),
                left: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 0.2, // Lebar border
                ),
                right: BorderSide(
                  color: Colors.grey, // Warna border
                  width: 0.2, // Lebar border
                ),
              ),
            ),
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
                          color: Color.fromARGB(255, 238, 238, 238),
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(foundTenant[index].gambar),
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: Text(
                              foundTenant[index].namaTenant,
                              // style: Judul(),
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: bold,
                              ),
                            ),
                          ),
                          Text(
                            foundTenant[index].namaKavling,
                            // style: SubJudul(),
                            style: GoogleFonts.poppins(
                              color: primaryextColor,
                              fontSize: 12,
                              fontWeight: semibold,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            "Mulai harga $range",
                            // style: Deskripsi(),
                            style: GoogleFonts.poppins(
                              color: secondaryTextColor,
                              fontSize: 12,
                              fontWeight: regular,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
    ;
  }
}
