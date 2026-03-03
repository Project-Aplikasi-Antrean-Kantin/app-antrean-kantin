import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/item_option.dart';

class DeliveryOption extends StatelessWidget {
  final int? roomId;
  final int isPriority;
  final int ongkirReguler;
  final int ongkirExpress;
  final VoidCallback onTapExpress;
  final VoidCallback onTapReguler;

  const DeliveryOption({
    super.key,
    this.roomId,
    required this.isPriority,
    required this.ongkirReguler,
    required this.ongkirExpress,
    required this.onTapExpress,
    required this.onTapReguler,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 8,
        children: [
          ItemOption(
            isSelected: isPriority == 1,
            title: "Express",
            price: roomId == null
                ? "-"
                : FormatCurrency.intToStringCoin(ongkirExpress),
            onTap: onTapExpress,
            leadingIcon: Iconsax.flash_1,
            description: roomId != null
                ? "Jaminan pesan tidak tertolak, lebih cepat sampai tempatmu"
                : null,
          ),
          ItemOption(
            isSelected: isPriority == 0,
            title: "Reguler",
            price: roomId == null
                ? "-"
                : FormatCurrency.intToStringCoin(ongkirReguler),
            onTap: onTapReguler,
          ),
        ],
      ),
    );
  }
}
