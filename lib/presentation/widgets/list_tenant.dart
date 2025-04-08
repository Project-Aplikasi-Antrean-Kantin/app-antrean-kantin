import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class ListTenant extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final url;
  final List<TenantModel> foundTenant;

  const ListTenant({
    super.key,
    required this.url,
    required this.foundTenant,
  });

  Route MenuTenantPage(index) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MenuTenant(
        url: '$url/${foundTenant[index].id}',
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // route builder geser + pudar
  // Route MenuTenantPage(index) {
  //   return PageRouteBuilder(
  //     pageBuilder: (context, animation, secondaryAnimation) => MenuTenant(
  //       url: '$url/${foundTenant[index].id}',
  //     ),
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       var curve = Curves.easeInOut;
  //       var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
  //           .chain(CurveTween(curve: curve));

  //       return SlideTransition(
  //         position: animation.drive(tween),
  //         child: FadeTransition(
  //           opacity: animation,
  //           child: child,
  //         ),
  //       );
  //     },
  //   );
  // }

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
            Navigator.push(context, MenuTenantPage(index));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Column(
              children: [
                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        const ShimmerLoadingWidget(
                          shimmerContainerImage: true,
                          padding: EdgeInsets.zero,
                          heightContainerImage: 170,
                          widhtContainerImage: double.infinity,
                        ),
                        foundTenant[index].gambar.isNotEmpty
                            ? Image.network(
                                foundTenant[index].gambar,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 170,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const ShimmerLoadingWidget(
                                    shimmerContainerImage: true,
                                    padding: EdgeInsets.zero,
                                    heightContainerImage: 170,
                                    widhtContainerImage: double.infinity,
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/dummy.jpeg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 170,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/dummy.jpeg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 170,
                              ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    border: Border(
                      right: BorderSide(
                        width: 0.2,
                        color: AppColors.containerColorGrey,
                      ),
                      left: BorderSide(
                        width: 0.2,
                        color: AppColors.containerColorGrey,
                      ),
                      bottom: BorderSide(
                        width: 0.2,
                        color: AppColors.containerColorGrey,
                      ),
                    ),
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
                                color: AppColors.textColorBlack,
                                fontSize: 16,
                                fontWeight: semibold,
                              ),
                            ),
                            Text(
                              "Aneka makanan, makanan dan snack kantin pens",
                              // style: Judul(),
                              style: GoogleFonts.poppins(
                                color: AppColors.textColorBlack,
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
                          border: Border.all(
                            width: 0.3,
                            color: AppColors.containerColorGrey,
                          ),
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
                              color: AppColors.textColorBlack,
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
