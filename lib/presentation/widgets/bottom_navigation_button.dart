import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class BottomNavigationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final Color color;

  const BottomNavigationButton({
    Key? key,
    required this.isLoading,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 10),
      height: MediaQuery.of(context).size.height * 0.075,
      decoration: BoxDecoration(
        color: isLoading ? Colors.grey : color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        enableFeedback: !isLoading,
        onTap: isLoading ? null : onTap,
        child: Align(
          alignment: Alignment.center,
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Tunggu sebentar",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Text(
                  "Pesan sekarang",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: semibold,
                  ),
                ),
        ),
      ),
    );
  }
}
