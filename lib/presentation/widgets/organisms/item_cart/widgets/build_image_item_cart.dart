import 'package:flutter/cupertino.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class BuildImageItemCart extends StatelessWidget {
  final CartMenuModel item;
  const BuildImageItemCart({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ImageByUrl(
        key: Key('${item.menuId}-${item.menuGambar}'),
        url: item.menuGambar,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      ),
    );
  }
}
