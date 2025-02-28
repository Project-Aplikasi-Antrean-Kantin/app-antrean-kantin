// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:testgetdata/core/theme/colors_theme.dart';
// import 'package:testgetdata/core/theme/text_theme.dart';
// import 'package:testgetdata/presentation/widgets/bottom_sheet_keranjang.dart';

// class PilihLokasiRuangan extends StatelessWidget {
//   final int? selectedLocation;
//   final Function(int?)? onLocationSelected;
//   final listRuangan;
//   final String token;

//   PilihLokasiRuangan({
//     required this.listRuangan,
//     required this.token,
//     this.selectedLocation,
//     this.onLocationSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     print(listRuangan);
//     return Column(
//       children: [
//         Container(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'Lokasi Pengantaran',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: semibold,
//               color: AppColors.textColorBlack,
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         GestureDetector(
//           onTap: () {
//             bottomSheetLokasiRuangan(context, listRuangan, (option) {
//               if (onLocationSelected != null) {
//                 onLocationSelected!(option);
//               }
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 10,
//               horizontal: 25,
//             ),
//             height: MediaQuery.of(context).size.width * 0.18,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(10),
//               ),
//               border: Border.all(
//                 color: Colors.grey,
//                 width: 0.2,
//               ),
//             ),
//             child: Row(
//               children: [
//                 if (selectedLocation != null) Icon(Icons.location_on),
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: selectedLocation != null ? 25 : 0,
//                     ),
//                     alignment: Alignment.centerLeft,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         selectedLocation == null
//                             ? Text(
//                                 'Silahkan pilih ruangan',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                 ),
//                               )
//                             // : Text('haha')
//                             : Text(
//                                 listRuangan
//                                     .where((element) =>
//                                         element.id == selectedLocation)
//                                     .first
//                                     .namaRuangan
//                                     .toString(),
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Icon(Icons.arrow_drop_down),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class PilihLokasiRuangan extends StatefulWidget {
  final int? selectedLocation;
  final Function(int?)? onLocationSelected;
  final List<dynamic> listRuangan;
  final String token;

  PilihLokasiRuangan({
    required this.listRuangan,
    required this.token,
    this.selectedLocation,
    this.onLocationSelected,
  });

  @override
  _PilihLokasiRuanganState createState() => _PilihLokasiRuanganState();
}

class _PilihLokasiRuanganState extends State<PilihLokasiRuangan> {
  int? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Lokasi Pengantaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: semibold,
              color: AppColors.textColorBlack,
            ),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonHideUnderline(
          child: DropdownButton2<int>(
            isExpanded: true,
            hint: Text(
              'Silahkan pilih ruangan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textColorBlack,
              ),
            ),
            items: widget.listRuangan
                .map((ruangan) => DropdownMenuItem<int>(
                      value: ruangan.id,
                      child: Text(
                        ruangan.namaRuangan.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textColorBlack,
                          fontWeight: regular,
                        ),
                      ),
                    ))
                .toList(),
            value: selectedValue,
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
              if (widget.onLocationSelected != null) {
                widget.onLocationSelected!(value);
              }
            },
            buttonStyleData: ButtonStyleData(
                height: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.2,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                )),
            dropdownStyleData: const DropdownStyleData(
              maxHeight: 200,
              elevation: 4,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                // color: AppColors.debugColor,
                height: MediaQuery.of(context).size.width * 0.15,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'Cari nama ruangan...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textColorBlack,
                      fontWeight: regular,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                if (item.value == null) return false;
                return widget.listRuangan
                    .firstWhere((ruangan) => ruangan.id == item.value)
                    .namaRuangan
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                textEditingController.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}
