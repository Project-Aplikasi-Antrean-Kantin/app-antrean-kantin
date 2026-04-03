import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class BottomNavigationBarForm extends StatelessWidget {
  final String confirmText;
  final bool isLoading;

  final Future<void> Function() onConfirm;
  const BottomNavigationBarForm(
      {super.key,
      required this.confirmText,
      required this.isLoading,
      required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // harus ada agar shadow muncul
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent, // tidak ada shadow
                    surfaceTintColor: Colors.transparent, // hilangkan efek tint
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color.fromARGB(255, 68, 68, 68),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await onConfirm();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent, // tidak ada shadow
                    surfaceTintColor: Colors.transparent, // hilangkan efek tint
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          confirmText,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
