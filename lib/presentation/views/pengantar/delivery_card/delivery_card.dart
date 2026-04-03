import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/action_button/action_button_delivery.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/cost_section_delivery.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/delivery_info.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/delivery_list_item.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/widgets/header_delivery_card.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class DeliveryCard extends StatefulWidget {
  final VoidCallback onSuccess;
  final Pesanan pesanan;
  final int lengthListPesanan;
  final int ongkir;
  final DeliveryStatus status;
  final String userToken;
  final int index;
  final int userId;
  final bool showChatOnly;

  const DeliveryCard({
    required this.lengthListPesanan,
    required this.showChatOnly,
    required this.userId,
    required this.index,
    required this.ongkir,
    Key? key,
    required this.onSuccess,
    required this.pesanan,
    required this.status,
    required this.userToken,
  }) : super(key: key);

  @override
  State<DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends State<DeliveryCard> {
  @override
  Widget build(BuildContext context) {
    final pesanan = widget.pesanan;

    final bool isMultiTenantHidden = widget.lengthListPesanan == 1;

    final bool showOrderInfo = isMultiTenantHidden;

    final bool showDividerTop = isMultiTenantHidden;

    final bool showCostDivider = isMultiTenantHidden;

    final bool showActionButton = pesanan.multitenantId == null ||
        pesanan.isPriority == 1 ||
        widget.lengthListPesanan == 1 ||
        widget.showChatOnly;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.whiteColor900, width: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderDeliveryCard(
              pesanan: pesanan,
              lengthListPesanan: widget.lengthListPesanan,
              isMultiTenantHidden: isMultiTenantHidden),
          if (showDividerTop)
            DashedDivider(color: AppColors.blackColor100, height: 2),
          if (showOrderInfo)
            DeliveryInfo(status: widget.status, pesanan: pesanan),
          DashedDivider(color: AppColors.blackColor100, height: 2),
          DeliveryListItem(
              pesanan: pesanan,
              index: widget.index,
              lengthListPesanan: widget.lengthListPesanan),
          if (showCostDivider)
            DashedDivider(color: AppColors.blackColor100, height: 2),
          CostSectionDelivery(
              pesanan: pesanan,
              lengthListPesanan: widget.lengthListPesanan,
              ongkir: widget.ongkir),
          if (showActionButton)
            ActionButtonDelivery(
                status: widget.status,
                pesanan: pesanan,
                token: widget.userToken,
                onSuccess: widget.onSuccess),
        ],
      ),
    );
  }
}
