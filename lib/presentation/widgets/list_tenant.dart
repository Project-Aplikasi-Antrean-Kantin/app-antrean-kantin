import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class ListTenant extends StatelessWidget {
  final String url;
  final List<TenantModel> foundTenant;
  final void Function(Widget page) onNavigate;

  const ListTenant({
    Key? key,
    required this.url,
    required this.foundTenant,
    required this.onNavigate,
  }) : super(key: key);

  // Helper untuk cek apakah salah satu menu punya gambar
  bool tenantHasMenuWithImage(TenantModel tenant) {
    if (tenant.tenantFoods == null || tenant.tenantFoods!.isEmpty) return false;
    return tenant.tenantFoods!.any(
        (food) => food.gambar != null && food.gambar.toString().isNotEmpty);
  }

  double menuImageCompleteness(TenantModel tenant) {
    final total = tenant.tenantFoods?.length ?? 0;
    if (total == 0) return 0.0;
    final withImage = tenant.tenantFoods!
        .where(
            (food) => food.gambar != null && food.gambar.toString().isNotEmpty)
        .length;
    return withImage / total;
  }

  @override
  Widget build(BuildContext context) {
    // Prioritas sorting:
    // 1. Online di atas offline
    // 2. Tenant yang punya gambar di salah satu menu di atas yang tidak punya
    // 3. Tenant dengan menu di atas yang tidak punya menu
    // 4. tenant.gambar tidak kosong di atas yang kosong
    // 5. Jika semua sama, biarkan urutan asli

    final List<TenantModel> sortedTenant = List<TenantModel>.from(foundTenant)
      ..sort((a, b) {
        // 1. Online di atas offline
        final aOnline = a.isOnline == true ? 1 : 0;
        final bOnline = b.isOnline == true ? 1 : 0;
        if (aOnline != bOnline) return bOnline.compareTo(aOnline);

        // 2. Persentase kelengkapan gambar menu (semakin tinggi semakin atas)
        final aPercent = menuImageCompleteness(a);
        final bPercent = menuImageCompleteness(b);
        if (aPercent != bPercent) return bPercent.compareTo(aPercent);

        // 3. Tenant dengan menu di atas yang tidak punya menu
        final aHasMenu = (a.tenantFoods?.isNotEmpty ?? false) ? 1 : 0;
        final bHasMenu = (b.tenantFoods?.isNotEmpty ?? false) ? 1 : 0;
        if (aHasMenu != bHasMenu) return bHasMenu.compareTo(aHasMenu);

        // 4. tenant.gambar tidak kosong di atas yang kosong
        final aHasGambar =
            a.gambar != null && a.gambar.toString().isNotEmpty ? 1 : 0;
        final bHasGambar =
            b.gambar != null && b.gambar.toString().isNotEmpty ? 1 : 0;
        if (aHasGambar != bHasGambar) return bHasGambar.compareTo(aHasGambar);

        // 5. Jika semua sama, urutan asli
        return 0;
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 1),
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedTenant.length,
      itemBuilder: (context, index) {
        final tenant = sortedTenant[index];

        return GestureDetector(
          onTap: () {
            if (tenant.isOnline == true) {
              debugPrint(url);
              onNavigate(MenuTenant(url: '$url/${tenant.id}'));
              log(tenant.isOnline.toString());
            } else {
              log(tenant.isOnline.toString());
              showDialog(
                context: context,
                builder: (context) {
                  return CustomAlertDialog(
                    title: 'Tenant Tidak Tersedia',
                    message:
                        'Tenant ini sedang tutup. Mungkin tenant sedang offline atau di luar jam operasional. Silakan coba lagi nanti.',
                    textButtonOk: 'Oke',
                    showCancelButton: false,
                    onOkPressed: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 15, left: 15, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              color: tenant.isOnline == true
                  ? AppColors.containerColorWhite
                  : Colors.grey.shade300,
            ),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    child: ColorFiltered(
                      colorFilter: tenant.isOnline == true
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply)
                          : const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                      child: Stack(
                        children: [
                          const ShimmerLoadingWidget(
                            shimmerContainerImage: true,
                            padding: EdgeInsets.zero,
                            heightContainerImage: 200,
                            widhtContainerImage: double.infinity,
                          ),
                          tenant.gambar != null && tenant.gambar.isNotEmpty
                              ? ImageByUrl(
                                  url: tenant.gambar,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                )
                              : Image.asset(
                                  'assets/images/dummy.jpeg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    tenant.namaTenant,
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textColorBlack,
                                        fontSize: 16,
                                        fontWeight: semibold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                tenant.isOnline == true
                                    ? const SizedBox.shrink()
                                    : Text(
                                        "Tutup",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: medium),
                                      ),
                              ],
                            ),
                            Text(
                              "Aneka makanan mulai dari " +
                                  FormatCurrency.intToStringCurrency(
                                      tenant.range ?? 0),
                              style: GoogleFonts.poppins(
                                color: AppColors.textColorBlack,
                                fontSize: 12,
                                fontWeight: FontWeight
                                    .w400, // Replace 'regular' with FontWeight.w400
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
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
                            tenant.namaKavling,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.textColorBlack,
                              fontWeight: bold,
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
