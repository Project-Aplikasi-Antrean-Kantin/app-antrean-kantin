import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class CardTenant extends StatelessWidget {
  final TenantModel tenant;
  final Color? backgroundColor;
  final List<TenantModel>? fullTenant;
  final String email;
  final List<TenantModel>? foundTenant;
  final Function(TenantModel tenant)? onNavigate;

  const CardTenant({
    super.key,
    required this.tenant,
    this.fullTenant,
    this.foundTenant,
    this.onNavigate,
    this.backgroundColor,
    required this.email,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTenantImage(),
                const SizedBox(width: 12),
                Expanded(child: _buildTenantInfo()),
              ],
            ),
            if (shouldShowHorizontalList) const SizedBox(height: 10),
            if (shouldShowHorizontalList) _buildHorizontalMenuList()
          ],
        ),
      ),
    );
  }

  Widget _buildTenantImage() {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: tenant.isOnline == true
            ? _buildImageWidget(112, 112, tenant.namaGambar.toString())
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
                child:
                    _buildImageWidget(112, 112, tenant.namaGambar.toString()),
              ));
  }

  Widget _buildImageWidget(double width, double height, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ImageByUrl(
        url: url,
        width: width,
        fit: BoxFit.cover,
        height: height,
      ),
    );
  }

  Widget _buildTenantInfo() {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedTimeSetting03,
              color: tenant.isOnline == true
                  ? tenant.busyUntil != null
                      ? AppColors.warningColor
                      : AppColors.successColor
                  : AppColors.errorColor,
            ),
            const SizedBox(width: 4),
            Text(
              tenant.isOnline == true
                  ? tenant.busyUntil != null
                      ? 'Sibuk'
                      : 'Buka'
                  : 'Tutup',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
            const SizedBox(width: 4),
            const Text('|'),
            const SizedBox(width: 4),
            Text(
              '${tenant.jamBuka?.substring(0, 5) ?? '09:30'} - ${tenant.jamTutup?.substring(0, 5) ?? '17:00'}',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
          ],
        ),
        Text(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          tenant.namaTenant,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingBasket01,
                color: AppColors.secondaryColor),
            const SizedBox(width: 4),
            Text(
              tenant.transaksiBerhasil.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'pesanan berhasil',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
            )
          ],
        ),
        Text(
          'Harga mulai dari ${tenant.range}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
                        ? _buildImageWidget(96, 96, food.gambar!)
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
                            child: _buildImageWidget(96, 96, food.gambar!),
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
