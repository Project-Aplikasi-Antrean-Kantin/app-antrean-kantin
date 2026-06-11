import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';

class InfoItemCart extends StatelessWidget {
  final CartMenuModel item;
  final VoidCallback onEdit;
  const InfoItemCart({super.key, required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.menuNama}',
            style: GoogleFonts.poppins(fontWeight: semibold),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          item.catatan != '' && item.catatan != null
              ? Text(
                  '${item.catatan}',
                  style:
                      TextStyle(color: AppColors.blackColor200, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )
              : Text(
                  'Catatan Kosong',
                  style:
                      TextStyle(color: AppColors.blackColor200, fontSize: 12),
                ),
          Semantics(
            identifier: 'Edit-${item.menuNama}-${item.catatan}',
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.infoColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      Iconsax.edit,
                      size: 16,
                      color: AppColors.whiteColor,
                    ),
                    Text(
                      'Edit',
                      style: GoogleFonts.poppins(color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
