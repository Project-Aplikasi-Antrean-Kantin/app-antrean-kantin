import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/widgets/menu_tenant.dart';
import 'package:testgetdata/core/theme/theme.dart';

class ListTenant extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
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
      padding: const EdgeInsets.only(bottom: 1),
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: foundTenant.length,
      itemBuilder: (context, index) {
        // return Text('data');
        return GestureDetector(
          onTap: () {
            debugPrint(url);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return MenuTenant(
                  url: '$url/${foundTenant[index].id}',
                );
              },
            ));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      //   image: NetworkImage(
                      //     foundTenant[index].gambar,
                      //   ),
                      //   fit: BoxFit.cover,
                      // ),
                      image: foundTenant[index].gambar.isNotEmpty
                          ? NetworkImage(foundTenant[index].gambar)
                          : AssetImage('assets/images/dummy.jpeg')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 170,
                  width: double.infinity,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foundTenant[index].namaTenant,
                              // style: Judul(),
                              style: GoogleFonts.poppins(
                                color: secondaryTextColor,
                                fontSize: 16,
                                fontWeight: semibold,
                              ),
                            ),
                            Text(
                              "Aneka makanan, makanan dan snack kantin pens",
                              // style: Judul(),
                              style: GoogleFonts.poppins(
                                color: primaryTextColor,
                                fontSize: 12,
                                fontWeight: regular,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(
                            foundTenant[index].namaKavling,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: secondaryTextColor,
                              fontWeight: FontWeight
                                  .bold, // Corrected to use FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
