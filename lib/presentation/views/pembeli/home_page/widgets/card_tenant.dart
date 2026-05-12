import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/organisms/tenant_info_with_image/tenant_info_with_image.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class CardTenant extends StatelessWidget {
  final TenantModel tenant;
  final Color? backgroundColor;
  final List<TenantModel>? fullTenant;
  final List<TenantModel>? foundTenant;
  final Function(TenantModel tenant)? onNavigate;

  const CardTenant({
    super.key,
    required this.tenant,
    this.fullTenant,
    this.foundTenant,
    this.onNavigate,
    this.backgroundColor,
  });

  bool get shouldShowHorizontalList =>
      fullTenant != null &&
      foundTenant != null &&
      fullTenant!.length != foundTenant!.length;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tenant.isOnline == true && onNavigate != null) {
          onNavigate!(tenant);
        } else {
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
        color: backgroundColor ?? Colors.transparent,
        margin: const EdgeInsets.only(right: 24, left: 24, bottom: 10),
        child: Column(
          children: [
            TenantInfoWithImage(
              tenant: tenant,
            ),
            if (shouldShowHorizontalList) const SizedBox(height: 10),
            if (shouldShowHorizontalList) _buildHorizontalMenuList()
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMenuList() {
    if (tenant.tenantFoods == null || tenant.tenantFoods!.isEmpty)
      return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tenant.tenantFoods?.length ?? 0,
        itemBuilder: (context, index) {
          final food = tenant.tenantFoods![index];
          return Padding(
            padding: index == 0
                ? const EdgeInsets.only(right: 8, top: 8, bottom: 8)
                : const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (food.gambar != null && food.gambar!.isNotEmpty)
                    tenant.isOnline == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageByUrl(
                              url: food.gambar!,
                              width: 96,
                              fit: BoxFit.cover,
                              height: 96,
                            ),
                          )
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ImageByUrl(
                                url: food.gambar!,
                                width: 96,
                                fit: BoxFit.cover,
                                height: 96,
                              ),
                            ),
                          )
                  else
                    Image.asset(
                      'assets/images/dummy.jpeg',
                      fit: BoxFit.cover,
                      height: 144,
                      width: 144,
                    ),
                  const SizedBox(height: 5),
                  Text(
                    FormatCurrency.intToStringCurrency(food.harga),
                  ),
                  Text(
                    food.nama.length <= 30
                        ? food.nama
                        : '${food.nama.substring(0, 30)}...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
