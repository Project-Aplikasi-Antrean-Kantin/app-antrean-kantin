import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/custom_form_field.dart';

class TimePicker extends StatelessWidget {
  final String label;
  final String selectedTime;
  final Function(String) onTimeChanged;

  const TimePicker({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(selectedTime.split(":")[0]),
        minute: int.parse(selectedTime.split(":")[1]),
      ),
    );

    if (timeOfDay != null) {
      final formattedTime =
          "${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}:00";
      onTimeChanged(formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextFormField(
              onTap: () => _pickTime(context),
              decoration: InputDecoration(
                hintText: "00:00",
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.blackColor100,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.blackColor100,
                    width: 1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
              ),
              readOnly: true,
              controller: TextEditingController(text: selectedTime),
            ),
          ),
          GestureDetector(
            onTap: () => _pickTime(context),
            child: Container(
              height: 56, // Samakan tinggi dengan TextFormField
              width: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedClock02,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
