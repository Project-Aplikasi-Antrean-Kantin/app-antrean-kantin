import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/card_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ListTenant extends StatefulWidget {
  final List<TenantModel> fullTenant;
  final String url;
  final List<TenantModel> foundTenant;
  final void Function(Widget page) onNavigate;

  const ListTenant({
    Key? key,
    required this.url,
    required this.foundTenant,
    required this.onNavigate,
    required this.fullTenant,
  }) : super(key: key);

  @override
  State<ListTenant> createState() => _ListTenantState();
}

class _ListTenantState extends State<ListTenant> {
  bool _isNavigating = false;
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final List<TenantModel> sortedTenant =
        List<TenantModel>.from(widget.foundTenant)
          ..sort((a, b) {
            final aOnline = a.isOnline == true ? 1 : 0;
            final bOnline = b.isOnline == true ? 1 : 0;
            if (aOnline != bOnline) return bOnline.compareTo(aOnline);

            // final aPercent = menuImageCompleteness(a);
            // final bPercent = menuImageCompleteness(b);
            // if (aPercent != bPercent) return bPercent.compareTo(aPercent);

            // final aHasMenu = (a.tenantFoods?.isNotEmpty ?? false) ? 1 : 0;
            // final bHasMenu = (b.tenantFoods?.isNotEmpty ?? false) ? 1 : 0;
            // if (aHasMenu != bHasMenu) return bHasMenu.compareTo(aHasMenu);

            // final aHasGambar =
            //     a.gambar != null && a.gambar.toString().isNotEmpty ? 1 : 0;
            // final bHasGambar =
            //     b.gambar != null && b.gambar.toString().isNotEmpty ? 1 : 0;
            // if (aHasGambar != bHasGambar) return bHasGambar.compareTo(aHasGambar);

            // Tambahkan sorting berdasarkan transaksiBerhasil
            return (b.transaksiBerhasil ?? 0)
                .compareTo(a.transaksiBerhasil ?? 0);
          });
    if (sortedTenant.isEmpty) {
      return Center(
        child: Text(
          'Data tidak ditemukan',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.blackColor,
          ),
        ),
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      padding: const EdgeInsets.only(bottom: 1),
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedTenant.length,
      itemBuilder: (context, index) {
        final tenant = sortedTenant[index];

        return CardTenant(
          email: authProvider.user.email,
          tenant: tenant,
          fullTenant: widget.fullTenant,
          foundTenant: widget.foundTenant,
          onNavigate: (tenant) async {
            if (_isNavigating) return;
            _isNavigating = true;
            final internetConnection = await hasInternetAccess();
            if (!internetConnection) {
              showNoConnectionBottomSheet(context: context, onRetry: () {});
              return;
            }

            Navigator.push(
                context,
                CustomPageBuilder(
                  page: MenuTenant(
                    url: '${widget.url}/${tenant.id}',
                  ),
                )).then((value) => _isNavigating = false);
          },
        );
      },
    );
  }
}
