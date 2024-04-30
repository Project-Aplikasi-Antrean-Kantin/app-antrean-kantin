import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  final String status;
  final String message;

  CustomSnackBar({required this.status, required this.message})
      : super(
          content: Row(
            children: [
              const Icon(Icons.error,
                  color: Colors.white), // Tambahkan ikon (opsional)
              const SizedBox(width: 10), // Beri jarak antara ikon dan teks
              Expanded(
                child: Text(
                  message, // Tampilkan pesan kesalahan
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: status == 'success' ? Colors.blue : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        );
}
