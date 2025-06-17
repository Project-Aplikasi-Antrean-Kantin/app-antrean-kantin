import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showTopBorder;
  final bool showBottomBorder;

  const ProfileMenuTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showTopBorder = true,
    this.showBottomBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            top: showTopBorder
                ? BorderSide(width: 0.2, color: Colors.grey[900]!)
                : BorderSide.none,
            bottom: showBottomBorder
                ? BorderSide(width: 0.2, color: Colors.grey[900]!)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                icon,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
            ),
            const Spacer(flex: 1),
            const Icon(
              Icons.arrow_right,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
