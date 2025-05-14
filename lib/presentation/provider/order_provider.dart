import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/order_tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';

class OrderProvider with ChangeNotifier {
  final Map<OrderStatus, List<Pesanan>> _pesanan = {
    OrderStatus.pesananMasuk: [],
    OrderStatus.pesananDiproses: [],
    // OrderStatus.pesananMenunggu: [],
  };
  bool _isLoading = false;
  bool _isLoadingItem = false;

  List<Pesanan> getPesananByStatus(OrderStatus status) => _pesanan[status]!;
  bool get isLoading => _isLoading;
  bool get isLoadingItem => _isLoadingItem;

  Future<void> fetchOrders(
      BuildContext context, String token, OrderStatus status) async {
    _isLoading = true;
    try {
      final orders = await OrderTenantRemoteDataSource()
          .getOrderCustomer(context, token, status.value);
      _pesanan[status] = orders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrder(
      String status, String auth, int id, Pesanan pesanan) async {
    if (_isLoadingItem) return false; // Prevent concurrent updates
    _isLoadingItem = true;
    notifyListeners();
    try {
      final success = await OrderTenantRemoteDataSource()
          .updateOrderCustomer(status, auth, id);
      if (success) {
        if (status == 'pesanan_diproses') {
          _pesanan[OrderStatus.pesananMasuk]!
              .removeWhere((element) => element.id == id);
          _pesanan[OrderStatus.pesananDiproses]!.add(pesanan);
        } else if (status == 'pesanan_ditolak') {
          _pesanan[OrderStatus.pesananMasuk]!
              .removeWhere((element) => element.id == id);
        } else if (status == 'siap_diantar' || status == 'selesai') {
          _pesanan[OrderStatus.pesananDiproses]!
              .removeWhere((element) => element.id == id);
        }
      }
      return success;
    } catch (e) {
      debugPrint('Error updating order: $e');
      return false;
    } finally {
      _isLoadingItem = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String auth, int id) async {
    final success =
        await OrderTenantRemoteDataSource().cancelOrderCustomer(auth, id);
    if (success) {
      _pesanan[OrderStatus.pesananMasuk]!
          .removeWhere((element) => element.id == id);
      notifyListeners();
    }
    return success;
  }
}
