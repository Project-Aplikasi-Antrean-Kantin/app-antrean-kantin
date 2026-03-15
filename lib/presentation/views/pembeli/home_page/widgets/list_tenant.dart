import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/home_page/widgets/card_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
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

  @override
  Widget build(BuildContext context) {
    final List<TenantModel> sortedTenant =
        List<TenantModel>.from(widget.foundTenant)
          ..sort((a, b) {
            final aOnline = a.isOnline == true ? 1 : 0;
            final bOnline = b.isOnline == true ? 1 : 0;
            if (aOnline != bOnline) return bOnline.compareTo(aOnline);

            // Tambahkan sorting berdasarkan transaksiBerhasil
            return (b.transaksiBerhasil).compareTo(a.transaksiBerhasil);
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
