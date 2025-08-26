import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';
import 'package:testgetdata/presentation/views/common/http_exception.dart';

enum DeliveryStatus {
  siapDiantar('siap_diantar', 'Siap Diambil'),
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
  String? _errorMessage; // Store error message for UI feedback

  List<Pesanan> getPesananByStatus(DeliveryStatus status) => _pesanan[status]!;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders(String token, DeliveryStatus status) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final pesanan =
          await DriverDataSource().getOrderDelivery(token, status.value);
      _pesanan[status] = pesanan.pesanan ?? [];
      print('Fetched orders: ${_pesanan[status]}');
      print('Result error: ${pesanan.error}');

      if (pesanan.error != null) {
        _errorMessage = pesanan.error;
      }
    } catch (e) {
      print('Error fetching orders: $e');

      _errorMessage = e.toString();
      rethrow; // Let the widget handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<({bool success, String? error})> updateOrder(
    String newStatus,
    String token,
    int id,
    Pesanan pesanan,
  ) async {
    if (_isLoading) return (success: false, error: 'Masih memuat...');
    _isLoading = true;
    notifyListeners();

    try {
      final success =
          await DriverDataSource().updateOrderDelivery(newStatus, token, id);
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
      return (success: success, error: null);
    } catch (e) {
      String error = 'Terjadi kesalahan';
      if (e is CustomHttpException && e.statusCode == 403) {
        error = e.message;
        await fetchOrders(token, DeliveryStatus.siapDiantar);
      } else {
        error = 'Error: $e';
      }
      return (success: false, error: error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
