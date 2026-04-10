import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/check_button.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/more_text.dart';

class HeaderCartPerTenant extends StatelessWidget {
  final VoidCallback onCheck;
  final bool onChecked;
  final VoidCallback onTapMore;
  final String tenantName;

  const HeaderCartPerTenant(
      {super.key,
      required this.onCheck,
      required this.onChecked,
      required this.tenantName,
      required this.onTapMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.75,
          ),
          child: Row(
            spacing: 8,
            children: [
              Semantics(
                  button: true,
                  child: CheckButton(
                    onCheck: onCheck,
                    onChecked: onChecked,
                    key: Key('Check Tenant ${tenantName}'),
                  )),
              Expanded(
                child: Text('${tenantName}',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        MoreText(onTapMore: onTapMore, text: 'Menu Lain')
      ],
    );
  }
}
