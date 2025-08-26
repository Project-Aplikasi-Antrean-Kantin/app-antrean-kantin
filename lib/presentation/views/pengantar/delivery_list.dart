import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card.dart';

class DeliveryList extends StatelessWidget {
  final TabController? tabController;
  final DeliveryStatus status;
  final Future<void> Function() onRefresh;

  const DeliveryList({
    Key? key,
    required this.tabController,
    required this.status,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final user = authProvider.user;
    final pesanan = deliveryProvider.getPesananByStatus(status);

    return RefreshIndicator(
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: pesanan.length,
        itemBuilder: (context, index) {
          final pesananItem = pesanan[index];
          return DeliveryCard(
            onSuccess: () {
              tabController!.animateTo(1);
            },
            pesanan: pesananItem,
            status: status,
            userToken: user.token,
          );
        },
      ),
    );
  }
}
