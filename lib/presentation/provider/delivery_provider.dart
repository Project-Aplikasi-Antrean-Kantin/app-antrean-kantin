// import 'package:flutter/material.dart';
// import 'package:testgetdata/data/model/pesanan_model.dart';
// import 'package:testgetdata/data/remote/driver_remote_data_source.dart';

// enum DeliveryStatus {
//   siapDiantar('siap_diantar', 'Menunggu'),
//   diantar('diantar', 'Diantar');

//   final String value;
//   final String label;

//   const DeliveryStatus(this.value, this.label);
// }

// class DeliveryProvider with ChangeNotifier {
//   Map<DeliveryStatus, List<Pesanan>> _pesanan = {
//     DeliveryStatus.siapDiantar: [],
//     DeliveryStatus.diantar: [],
//   };
//   bool _isLoading = false;

//   List<Pesanan> getPesananByStatus(DeliveryStatus status) => _pesanan[status]!;
//   bool get isLoading => _isLoading;

//   Future<void> fetchOrders(
//       BuildContext context, String token, DeliveryStatus status) async {
//     try {
//       _isLoading = true;
//       final pesanan =
//           await DriverDataSource().getOrderDelivery(token, status.value);
//       _pesanan[status] = pesanan;
//     } catch (e) {
//       // Handle error (e.g., show toast)
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> updateOrder(String newStatus, String token, int id,
//       [Pesanan? pesanan]) async {
//     try {
//       final success =
//           await DriverDataSource().updateOrderDelivery(newStatus, token, id);
//       if (success) {
//         if (newStatus == 'diantar' && pesanan != null) {
//           _pesanan[DeliveryStatus.siapDiantar] =
//               _pesanan[DeliveryStatus.siapDiantar]!
//                   .where((item) => item.id != id)
//                   .toList();
//           _pesanan[DeliveryStatus.diantar] = [
//             ..._pesanan[DeliveryStatus.diantar]!,
//             pesanan
//           ];
//         } else if (newStatus == 'selesai') {
//           _pesanan[DeliveryStatus.diantar] = _pesanan[DeliveryStatus.diantar]!
//               .where((item) => item.id != id)
//               .toList();
//         }
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       return false;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';

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

  List<Pesanan> getPesananByStatus(DeliveryStatus status) => _pesanan[status]!;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(
      BuildContext context, String token, DeliveryStatus status) async {
    try {
      _isLoading = true;
      final pesanan =
          await DriverDataSource().getOrderDelivery(token, status.value);
      _pesanan[status] = pesanan;
    } catch (e) {
      // Tampilkan pesan error ke pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pesanan: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrder(
      String newStatus, String token, int id, BuildContext context,
      [Pesanan? pesanan]) async {
    try {
      final success =
          await DriverDataSource().updateOrderDelivery(newStatus, token, id);
      if (success) {
        // Langsung refresh state dari server untuk semua status
        await Future.wait([
          fetchOrders(context, token, DeliveryStatus.siapDiantar),
          fetchOrders(context, token, DeliveryStatus.diantar),
        ]);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui pesanan')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }
}
