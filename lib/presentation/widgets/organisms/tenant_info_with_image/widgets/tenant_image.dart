import 'package:flutter/cupertino.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class TenantImage extends StatelessWidget {
  final TenantModel tenant;
  final double width;
  const TenantImage({super.key, required this.tenant, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: tenant.isOnline == true
            ? _buildImageWidget(width, width, tenant.namaGambar.toString())
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
                child: _buildImageWidget(
                    width, width, tenant.namaGambar.toString()),
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
}
