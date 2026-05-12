import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_list.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_empty_state.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';

class PesananOnlineTabView extends StatelessWidget {
  final OrderStatus status;
  final FlutterThermalPrinter printer;
  final OrderProvider orderProvider;
  final Future<void> Function() onRetry;

  const PesananOnlineTabView({
    Key? key,
    required this.status,
    required this.printer,
    required this.orderProvider,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orderProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: 2,
          itemBuilder: (_, __) =>
              ShimmerCard.buildPesananPageShimmer(status, printer),
        ),
      );
    }

    final pesanan = orderProvider.getPesananByStatus(status);

    if (pesanan.isEmpty) {
      return PesananEmptyState(
        status: status,
        errorMessage: orderProvider.errorMessage,
        onRetry: () {
          orderProvider.clearError();
          onRetry();
        },
      );
    }

    return PesananList(
      printer: printer,
      status: status,
      onRefresh: onRetry,
    );
  }
}
