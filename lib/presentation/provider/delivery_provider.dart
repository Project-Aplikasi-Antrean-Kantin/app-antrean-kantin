import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';
import 'package:testgetdata/presentation/views/common/http_exception.dart';

enum DeliveryStatus {
  siapDiantar('siap_diantar', 'Menunggu'),
  diantar('diantar', 'Diantar');

  final String value;
  final String label;

  const DeliveryStatus(this.value, this.label);
}

class DeliveryProvider with ChangeNotifier {
  Map<DeliveryStatus, List<Pesanan>> _pesanan = {
    DeliveryStatus.siapDiantar: [],
    DeliveryStatus.diantar: [],
  };
  bool _isLoading = false;
  bool _isLoadingItem = false;
  String? _errorMessage; // Store error message for UI feedback

  List<Pesanan> getPesananByStatus(DeliveryStatus status) => _pesanan[status]!;
  bool get isLoading => _isLoading;
  bool get isLoadingItem => _isLoadingItem;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders(String token, DeliveryStatus status) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      final pesanan =
          await DriverDataSource().getOrderDelivery(token, status.value);
      _pesanan[status] = pesanan;
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan: $e';
      rethrow; // Let the widget handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrder(
      String newStatus, String token, int id, Pesanan pesanan) async {
    if (_isLoadingItem) return false; // Prevent concurrent updates
    _isLoadingItem = true;
    notifyListeners();
    try {
      final success =
          await DriverDataSource().updateOrderDelivery(newStatus, token, id);
      // if (success) {
      //   _errorMessage = null;
      //   print('Success: _errorMessage cleared');
      //   notifyListeners();
      //   return true;
      // } else {
      //   _errorMessage = 'Gagal memperbarui pesanan';
      //   print('Failed: _errorMessage set to $_errorMessage');
      //   notifyListeners();
      //   return false;
      // }
      if (success) {
        if (newStatus == 'diantar') {
          _pesanan[DeliveryStatus.siapDiantar]!
              .removeWhere((element) => element.id == id);
          _pesanan[DeliveryStatus.diantar]!.add(pesanan);
        } else if (newStatus == 'selesai') {
          _pesanan[DeliveryStatus.diantar]!
              .removeWhere((element) => element.id == id);
        }
      }
      return success;
    } catch (e) {
      if (e is CustomHttpException && e.statusCode == 403) {
        _errorMessage = e.message;
        print('403 Error: _errorMessage set to $_errorMessage');
        await fetchOrders(token, DeliveryStatus.siapDiantar);
      } else {
        _errorMessage = 'Error: $e';
        print('Other Error: _errorMessage set to $_errorMessage');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoadingItem = false;
      notifyListeners();
    }
  }
}
