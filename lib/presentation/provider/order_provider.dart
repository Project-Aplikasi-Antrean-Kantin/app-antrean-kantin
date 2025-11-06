import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/order_tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';

class OrderProvider with ChangeNotifier {
  final Map<OrderStatus, List<Pesanan>> _pesanan = {
    OrderStatus.pesananMasuk: [],
    OrderStatus.pesananDiproses: [],
    OrderStatus.pesananSiapDiambil: [],
  };

  String? errorMessage;
  String? errorUpdate;

  bool _isLoading = false;

  List<Pesanan> getPesananByStatus(OrderStatus status) => _pesanan[status]!;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(
    BuildContext context,
    String token,
    OrderStatus status,
  ) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      List<Pesanan> allOrders = [];
      for (final value in status.rawValues) {
        final orders = await OrderTenantRemoteDataSource().getOrderCustomer(
          context,
          token,
          value,
        );
        allOrders.addAll(orders);
      }
      _pesanan[status] = allOrders;
    } catch (e) {
      errorMessage = 'Gagal memuat pesanan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateOrder(
    String status,
    String auth,
    int id,
    Pesanan pesanan,
  ) async {
    if (_isLoading) return false; // Prevent concurrent updates
    _isLoading = true;
    notifyListeners();
    try {
      final success = await OrderTenantRemoteDataSource().updateOrderCustomer(
        status,
        auth,
        id,
      );
      if (success.success) {
        if (status == 'pesanan_diproses') {
          _pesanan[OrderStatus.pesananMasuk]!.remove(pesanan);
          _pesanan[OrderStatus.pesananDiproses]!.add(pesanan);
        } else if (status == 'pesanan_ditolak') {
          _pesanan[OrderStatus.pesananMasuk]!.remove(pesanan);
        } else if (status == 'siap_diantar' || status == 'siap_diambil') {
          _pesanan[OrderStatus.pesananDiproses]!.remove(pesanan);
          _pesanan[OrderStatus.pesananSiapDiambil]!.add(pesanan);
        } else if (status == 'selesai') {
          _pesanan[OrderStatus.pesananSiapDiambil]!.remove(pesanan);
        }
      } else {
        errorUpdate = success.error;
      }
      return success.success;
    } catch (e) {
      errorUpdate = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(
    String auth,
    int id,
    Pesanan pesanan,
    String catatanPenolakan,
  ) async {
    if (_isLoading) return false; // Prevent concurrent updates
    _isLoading = true;
    notifyListeners();
    try {
      final success = await OrderTenantRemoteDataSource().cancelOrderCustomer(
        auth,
        id,
        catatanPenolakan,
      );
      if (success.success) {
        if (pesanan.status == 'pesanan_diproses') {
          _pesanan[OrderStatus.pesananDiproses]!.remove(pesanan);
        } else {
          _pesanan[OrderStatus.pesananMasuk]!.remove(pesanan);
        }
        notifyListeners();
      } else {
        errorUpdate = success.error;
      }
      return success.success;
    } catch (e) {
      errorUpdate = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
