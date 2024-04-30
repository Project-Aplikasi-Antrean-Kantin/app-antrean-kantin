import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'pesanan_masuk':
      return Colors.green;
    case 'pesanan_ditolak':
      return Colors.red;
    case 'pesanan_diproses':
      return Colors.yellow;
    case 'siap_diantar':
      return Colors.blue;
    case 'pending':
      return Colors.orange;
    case 'selesai':
      return Colors.purple;
    default:
      return Colors.black;
  }
}
