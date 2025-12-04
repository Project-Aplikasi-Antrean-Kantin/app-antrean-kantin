import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

// ignore: must_be_immutable
class SearchWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String tittle;
  final double paddingHorizontal;
  final double paddingVertical;
  double? formHeight;
  TextEditingController? controller;
  FocusNode? focusNode;

  SearchWidget({
    Key? key,
    required this.onChanged,
    required this.tittle,
    required this.paddingHorizontal,
    required this.paddingVertical,
    this.formHeight,
    this.controller,
    this.focusNode,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late ValueNotifier<Color> _iconColorNotifier;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _iconColorNotifier = ValueNotifier<Color>(Colors.grey);

    // Listener untuk warna icon
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _iconColorNotifier.value = AppColors.primaryColor;
      } else {
        _iconColorNotifier.value = Colors.grey;
      }
      setState(() {}); // update border
    });

    // Listener untuk tombol silang
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _iconColorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.paddingHorizontal,
        vertical: widget.paddingVertical,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: _focusNode.hasFocus
                ? AppColors.primaryColor
                : AppColors.backgroundColor,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 12,
          ),
          cursorColor: Colors.grey,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),

            // 🔍 ICON SEARCH
            prefixIcon: ValueListenableBuilder<Color>(
              valueListenable: _iconColorNotifier,
              builder: (context, color, child) {
                return HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01, color: color);
              },
            ),

            // ❌ TOMBOL CLEAR
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged("");
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  )
                : null,

            hintText: widget.tittle,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
