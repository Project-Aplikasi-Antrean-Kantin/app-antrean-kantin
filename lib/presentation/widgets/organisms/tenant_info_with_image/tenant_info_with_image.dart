import 'package:flutter/cupertino.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/widgets/organisms/tenant_info_with_image/widgets/tenant_image.dart';
import 'package:testgetdata/presentation/widgets/organisms/tenant_info_with_image/widgets/tenant_info.dart';

class TenantInfoWithImage extends StatelessWidget {
  final TenantModel tenant;
  final double width;
  const TenantInfoWithImage(
      {super.key, this.width = 112, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TenantImage(
          width: width,
          tenant: tenant,
        ),
        const SizedBox(width: 12),
        Expanded(
            child: TenantInfo(
          tenant: tenant,
        )),
      ],
    );
  }
}
