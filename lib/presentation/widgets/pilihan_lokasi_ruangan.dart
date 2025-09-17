import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'dart:developer' as developer;

import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';

class PilihLokasiRuangan extends StatefulWidget {
  final int? selectedLocation;
  final Function(int?)? onLocationSelected;
  final Function(String) onChange;
  final List<Ruangan> listRuangan;
  final String token;

  const PilihLokasiRuangan({
    required this.listRuangan,
    required this.token,
    this.selectedLocation,
    this.onLocationSelected,
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  _PilihLokasiRuanganState createState() => _PilihLokasiRuanganState();
}

class _PilihLokasiRuanganState extends State<PilihLokasiRuangan> {
  int? selectedValue;
  final TextEditingController textEditingController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      selectedValue = cartProvider.roomId;

      developer.log(
          "PilihLokasiRuangan init: selectedLocation = ${widget.selectedLocation}, selectedValue = $selectedValue");
      // Panggil onLocationSelected untuk menyinkronkan state
      if (widget.onLocationSelected != null && selectedValue != null) {
        widget.onLocationSelected!(selectedValue);
      }
    });
  }

  @override
  void didUpdateWidget(PilihLokasiRuangan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLocation != widget.selectedLocation) {
      setState(() {
        selectedValue = widget.selectedLocation;
      });
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
        "PilihLokasiRuangan build: selectedLocation = ${widget.selectedLocation}, selectedValue = $selectedValue");

    return Column(
      spacing: 8,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          child: Text(
            'Lokasi Pengantaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.blackColor400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            spacing: 8,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<int>(
                  iconStyleData: IconStyleData(
                      icon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.arrow_drop_down_outlined,
                      color: AppColors.textColorBlack,
                    ),
                  )),
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
                    developer.log(
                        "Dropdown onChanged: memilih ruangan dengan id = $value");
                    if (widget.onLocationSelected != null) {
                      widget.onLocationSelected!(value);
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.2,
                        color: Colors.grey,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
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
                      height: 60,
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
                            color: AppColors.textColorBlack.withOpacity(0.5),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Catatan Lokasi',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.blackColor,
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: AppColors.blackColor100,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text('Opsional',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.blackColor100, width: 2),
                ),
                height: 124,
                child: TextField(
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor200,
                    ),
                    hintText:
                        'Tambah detail catatan lokasi pengantaran (PS 19.45 Dekat Lift)',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      widget.onChange(value);
                    });
                  },
                  maxLines: 3,
                  maxLength: 200,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
