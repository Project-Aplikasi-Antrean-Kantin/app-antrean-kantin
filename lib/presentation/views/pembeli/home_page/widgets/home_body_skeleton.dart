import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/views/pembeli/home_page/widgets/card_tenant.dart';

class HomeBodySkeleton extends StatelessWidget {
  const HomeBodySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        shrinkWrap: true, // ✅ biar ukurannya sesuai isi
        physics: NeverScrollableScrollPhysics(), // ✅ biar gak scroll dobel
        padding: EdgeInsets.zero,
        itemCount: 7,
        itemBuilder: (context, index) {
          return CardTenant(
            tenant: TenantModel(
              id: 1,
              namaTenant: 'Bakso Pak Budi',
              namaKavling: 'Kavling A1',
              transaksiBerhasil: 120,
              gambar: 'https://example.com/images/bakso.jpg',
              userId: 10,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        },
      ),
    );
  }
}
