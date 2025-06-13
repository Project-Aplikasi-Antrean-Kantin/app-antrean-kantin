import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_card.dart';

class PesananList extends StatelessWidget {
  final OrderStatus status;
  final Future<void> Function() onRefresh;

  const PesananList({
    Key? key,
    required this.status,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;
    final pesanan = orderProvider.getPesananByStatus(status);

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pesanan.length,
          itemBuilder: (context, index) {
            final pesananItem = pesanan[index];
            return PesananCard(
              pesanan: pesananItem,
              status: status,
              token: user.token,
            );
          },
        ),
      ),
    );
  }
}
