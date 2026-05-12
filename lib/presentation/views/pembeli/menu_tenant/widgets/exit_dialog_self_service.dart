import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';

Future<bool?> showExitDialogSelfService(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  String secretCode = authProvider.settings
      .firstWhere((setting) => setting.nama == 'kode_self_service')
      .nilai; // 🔐 kode didefinisikan langsung

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Masukkan Kode'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Kode keluar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == secretCode) {
                Navigator.pop(context, true); // ✅ kode benar
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kode salah')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
