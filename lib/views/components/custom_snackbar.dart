import 'package:flutter/material.dart';
import 'package:testgetdata/views/theme.dart';

class CustomSnackBar extends SnackBar {
  final String status;
  final String message;

  CustomSnackBar({required this.status, required this.message})
      : super(
          content: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
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
          backgroundColor: status == 'success' ? Colors.blue : primaryColor,
          behavior: SnackBarBehavior.floating,
        );
}
