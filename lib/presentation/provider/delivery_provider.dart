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
    String? buktiPath,
  }) async {
    if (_isLoading) return (success: false, error: 'Masih memuat...');
    _isLoading = true;
    notifyListeners();

    try {
      ({Pesanan? pesanan, bool success}) response;

      // API call
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

      if (!response.success) {
        return (success: false, error: "Gagal update pesanan");
      }

      // ------------------------------------------------------
      // STEP 1 — Ambil affected orders (multitenant)
      // ------------------------------------------------------
      List<Pesanan> affected = [];

      if (pesanan.multitenantId != null) {
        affected = _pesanan.values
            .expand((l) => l)
            .where((p) => p.multitenantId == pesanan.multitenantId)
            .toList();
      }

      if (affected.isEmpty) {
        affected = [pesanan];
      }

      // === FIX: single berarti multitenantId null ATAU cuma 1 pesanan di group ===
      final bool isMultiTenantSingle =
          pesanan.multitenantId == null || affected.length == 1;

      // ------------------------------------------------------
      // STEP 2A — Hitung finalStatus **sementara** untuk tiap order
      // ------------------------------------------------------

      // Simpan mapping order.id -> finalStatus sementara
      final Map<int, String> tempFinalStatus = {};

      for (final order in affected) {
        String finalStatus = order.status;

        if (isMultiTenantSingle) {
          if (order.isPriority == 1 &&
              newStatus == 'diantar' &&
              order.driverId == null) {
            finalStatus = order.status;
          } else {
            finalStatus = newStatus;
          }
        } else {
          if (newStatus == 'diantar') {
            if (order.driverId == null) {
              if (order.status == 'siap_diantar') {
                finalStatus = 'diantar';
              } else {
                finalStatus = order.status; // hanya set driver
              }
            } else {
              finalStatus = (order.id == id) ? 'diantar' : order.status;
            }
          } else if (newStatus == 'pesanan_diproses') {
            if (order.status == 'diantar') {
              finalStatus = 'diantar';
            } else {
              finalStatus = 'pesanan_diproses';
            }
          } else if (newStatus == 'selesai') {
            finalStatus = 'selesai';
          }
        }

        tempFinalStatus[order.id] = finalStatus;
      }

      // ------------------------------------------------------
      // STEP 2B — Hitung groupHasDiantar berdasarkan FINAL STATUS
      // ------------------------------------------------------

      final bool groupHasDiantar =
          tempFinalStatus.values.any((s) => s == 'diantar');

      // ------------------------------------------------------
      // STEP 3 — Apply perubahan berdasarkan final group state
      // ------------------------------------------------------

      for (final order in affected) {
        final String finalStatus = tempFinalStatus[order.id]!;

        DeliveryStatus finalTab;

        if (isMultiTenantSingle) {
          finalTab = (finalStatus == 'diantar')
              ? DeliveryStatus.diantar
              : DeliveryStatus.siapDiantar;
        } else {
          finalTab = groupHasDiantar
              ? DeliveryStatus.diantar
              : DeliveryStatus.siapDiantar;
        }

        _pesanan[DeliveryStatus.siapDiantar]!
            .removeWhere((e) => e.id == order.id);
        _pesanan[DeliveryStatus.diantar]!.removeWhere((e) => e.id == order.id);

        // tambahkan final
        final updated = order.copyWith(
          driverId: userId,
          status: pesanan.id == order.id ? finalStatus : order.status,
        );

        if (finalStatus != 'selesai') {
          _pesanan[finalTab]!.add(updated);
        }
      }

      return (success: true, error: null);
    } catch (e) {
      String err = 'Terjadi kesalahan';
      if (e is CustomHttpException && e.statusCode == 403) {
        err = e.message;
      } else {
        err = 'Error: $e';
      }

      return (success: false, error: err);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
