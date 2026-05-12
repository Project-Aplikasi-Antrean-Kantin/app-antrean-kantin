import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/organisms/tenant_info_with_image/tenant_info_with_image.dart';

class SliverAppBarMenuTenant extends StatelessWidget {
  final TenantModel tenant;
  const SliverAppBarMenuTenant({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      pinned: false,
      expandedHeight: MediaQuery.of(context).size.height / 4.5,
      flexibleSpace: _buildFlexibleSpaceBar(tenant),
    );
  }

  Widget _buildFlexibleSpaceBar(TenantModel tenant) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner background
        Positioned.fill(
          child: FlexibleSpaceBar(
            background: ImageByUrl(
              url: tenant.namaGambar.toString(),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Back button

        // Card menimpa banner bagian bawah
        Positioned(
          bottom: -40, // menimpa keluar banner
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TenantInfoWithImage(
              tenant: tenant,
              width: 96,
            ),
          ),
        ),
      ],
    );
  }
}
