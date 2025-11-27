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
    int userId,
    String newStatus,
    String token,
    int id,
    DeliveryStatus deliveryStatus,
    Pesanan pesanan, {
    String? buktiPath, // opsional: bukti foto
  }) async {
    print("cek");
    if (_isLoading) return (success: false, error: 'Masih memuat...');
    _isLoading = true;
    notifyListeners();

    try {
      ({Pesanan? pesanan, bool success}) response;

      // ⬇️ Pilih API sesuai ada/tidaknya bukti foto
      if (buktiPath != null) {
        response = await DriverDataSource().updateOrderWithProof(
          newStatus,
          token,
          id,
          buktiPath,
        );
      } else {
        response = await DriverDataSource().updateOrderDelivery(
          newStatus,
          token,
          id,
        );
      }

      if (response.success) {
        // 🔹 Ambil semua pesanan dengan multitenantId yang sama
        List<Pesanan> affectedOrders = [];

        if (pesanan.multitenantId != null) {
          affectedOrders = _pesanan.values
              .expand((list) => list)
              .where((p) => p.multitenantId == pesanan.multitenantId)
              .toList();
        } else {
          affectedOrders = [pesanan];
        }
        print("affectedOrders: $affectedOrders");

        for (final order in affectedOrders) {
          final orderId = order.id;
          print("response pesanan: ${response.pesanan}");
          final pesananCopy = order.copyWith(driverId: userId);
          print("orderId: $orderId, pesanan: $order");
          print("_pesanan: ${_pesanan[DeliveryStatus.siapDiantar]}");
          if (newStatus == 'diantar') {
            // Kasus dari siap_diantar → diantar
            if ((order.status == 'siap_diantar' ||
                (order.multitenantId != null &&
                    (order.status == 'pesanan_diproses')))) {
              if (deliveryStatus == DeliveryStatus.siapDiantar) {
                _pesanan[DeliveryStatus.siapDiantar]!
                    .removeWhere((e) => e.id == orderId);
              } else {
                _pesanan[DeliveryStatus.diantar]!
                    .removeWhere((e) => e.id == orderId);
              }
              if (order.status == 'pesanan_diproses') {
                if (response.pesanan!.id == orderId) {
                  _pesanan[DeliveryStatus.diantar]!
                      .add(pesananCopy.copyWith(status: "diantar"));
                } else {
                  _pesanan[DeliveryStatus.diantar]!.add(pesananCopy);
                }
              } else {
                _pesanan[DeliveryStatus.diantar]!.add(
                    pesananCopy.copyWith(status: response.pesanan!.status));
              }
            } else {
              if (order.driverId == null) {
                _pesanan[DeliveryStatus.siapDiantar]!
                    .removeWhere((e) => e.id == orderId);
                _pesanan[DeliveryStatus.siapDiantar]!.add(pesananCopy);
              } else {
                if (affectedOrders.length == 1) {
                  _pesanan[DeliveryStatus.siapDiantar]!
                      .removeWhere((e) => e.id == orderId);
                  _pesanan[DeliveryStatus.diantar]!.add(response.pesanan!);
                } else {
                  if (order.status != 'diantar') {
                    _pesanan[DeliveryStatus.siapDiantar]!
                        .removeWhere((e) => e.id == orderId);
                    _pesanan[DeliveryStatus.diantar]!.add(pesananCopy);
                  }
                }
              }
            }
          } else if (newStatus == 'selesai') {
            _pesanan[DeliveryStatus.diantar]!
                .removeWhere((e) => e.id == orderId);
          } else if (newStatus == 'pesanan_diproses') {
            if ((order.multitenantId != null &&
                    order.isPriority == 1 &&
                    order.id == pesanan.id) ||
                order.multitenantId == null) {
              if (deliveryStatus == DeliveryStatus.siapDiantar) {
                _pesanan[DeliveryStatus.siapDiantar]!
                    .removeWhere((e) => e.id == orderId);

                _pesanan[DeliveryStatus.siapDiantar]!
                    .add(pesananCopy.copyWith(status: "pesanan_diproses"));
              } else {
                _pesanan[DeliveryStatus.diantar]!
                    .removeWhere((e) => e.id == orderId);
                _pesanan[DeliveryStatus.diantar]!
                    .add(pesananCopy.copyWith(status: "pesanan_diproses"));
              }
            }
          }
        }
      }

      return (success: response.success, error: null);
    } catch (e) {
      String error = 'Terjadi kesalahan';
      if (e is CustomHttpException && e.statusCode == 403) {
        print('Error message: ${e.message}');
        error = e.message;
      } else {
        error = 'Error: $e';
      }
      print('Error updating order: $error');
      return (success: false, error: error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
