import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class DetailFoodNote extends StatefulWidget {
  final TextEditingController controller;

  const DetailFoodNote({Key? key, required this.controller}) : super(key: key);

  @override
  State<DetailFoodNote> createState() => _DetailFoodNoteState();
}

class _DetailFoodNoteState extends State<DetailFoodNote> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        spacing: 4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catatan Untuk Tenant',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDCDCD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Opsional',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 124,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryColor, width: 1.5),
            ),
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan untuk tenant',
                hintStyle: TextStyle(fontSize: 14),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
                counter: SizedBox.shrink(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${widget.controller.text.length} / 200'),
          ),
        ],
      ),
    );
  }
}
