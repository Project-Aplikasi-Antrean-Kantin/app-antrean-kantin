import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class ListFilterDropdown extends StatelessWidget {
  final List<String> statusList;
  final bool isLoading;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool isDropdownOpen;
  final ValueChanged<bool> onMenuStateChange;

  const ListFilterDropdown(
      {super.key,
      required this.statusList,
      required this.isLoading,
      required this.selectedIndex,
      required this.onChanged,
      required this.isDropdownOpen,
      required this.onMenuStateChange});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: DropdownButtonHideUnderline(
        key: const Key('dropDownButton'),
        child: DropdownButton2<String>(
          isExpanded: true,
          value: statusList[selectedIndex],
          items: statusList.map((status) {
            return DropdownMenuItem<String>(
              key: Key("${status}Dropdown"),
              value: status,
              child: Row(
                children: [
                  Icon(Iconsax.tag, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(status,
                      style: GoogleFonts.poppins(
                          color: selectedIndex != 0
                              ? AppColors.primaryColor
                              : Colors.black,
                          fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            final index = statusList.indexOf(value);
            onChanged(index); // kirim ke parent
          },
          onMenuStateChange: (isOpen) => onMenuStateChange(isOpen),

          // === Customisasi dropdown utama ===
          buttonStyleData: ButtonStyleData(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selectedIndex != 0
                      ? AppColors.primaryColor
                      : Colors.grey.shade300),
              color: Colors.white,
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              isDropdownOpen ? Iconsax.arrow_up_1 : Iconsax.arrow_down,
              color: selectedIndex != 0 ? AppColors.primaryColor : Colors.black,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
