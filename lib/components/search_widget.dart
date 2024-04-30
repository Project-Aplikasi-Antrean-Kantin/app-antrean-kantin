import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchWidget({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        cursorColor: Colors.grey,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          hintText: "Cari menu kesukaanmu...",
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
