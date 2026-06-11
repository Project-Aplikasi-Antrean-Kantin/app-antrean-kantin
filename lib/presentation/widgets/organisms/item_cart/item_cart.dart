import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/molecules/counter/counter.dart';
import 'package:testgetdata/presentation/widgets/organisms/item_cart/widgets/build_image_item_cart.dart';
import 'package:testgetdata/presentation/widgets/organisms/item_cart/widgets/info_item_cart.dart';

class ItemCart extends StatelessWidget {
  final CartMenuModel item;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onCountChanged;

  const ItemCart({
    super.key,
    required this.item,

    // callbacks wajib
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuildImageItemCart(item: item),
              const SizedBox(width: 8),
              InfoItemCart(item: item, onEdit: onEdit),
            ],
          ),
        ),
        Column(
          spacing: 8,
          children: [
            Text(
              '${FormatCurrency.intToStringCurrency(item.menuPrice * item.count)}',
              style: GoogleFonts.poppins(),
            ),
            Counter(
                cartItem: item,
                onDecrement: onDecrement,
                count: item.count,
                onCountChanged: onCountChanged,
                widthEachButton: 36,
                heightEachButton: 36,
                onIncrement: onIncrement)
          ],
        )
      ],
    );
  }
}
