import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/organisms/image_picker_bottom_sheet/image_picker_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class DeliveryBottomSheet extends StatefulWidget {
  final VoidCallback onFinish;
  final bool canSend;
  final Function(String?) onImageSelected; // ⬅️ callback baru
  final bool onLoading;

  const DeliveryBottomSheet({
    super.key,
    required this.onFinish,
    required this.canSend,
    required this.onImageSelected,
    required this.onLoading,
  });

  @override
  State<DeliveryBottomSheet> createState() => _DeliveryBottomSheetState();
}

class _DeliveryBottomSheetState extends State<DeliveryBottomSheet> {
  String? selectedImagePath;

  /// Fungsi cek ukuran file dalam KB

  Future<void> _openImagePicker() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return ImagePickerBottomSheet(
          titleBottomSheet: 'Foto Menu',
          onImageSelected: (path) async {
            if (path == null) {
              setState(() {
                selectedImagePath = null;
              });
              return;
            }

            // optional validasi size
            final file = File(path);
            final sizeKB = await file.length() ~/ 1024;

            if (sizeKB > 2048) {
              showDialog(
                context: context,
                builder: (_) => CustomAlertDialog(
                  title: "Peringatan!",
                  message: "Gambar lebih dari 2MB",
                  showCancelButton: false,
                ),
              );
              return;
            }
            widget.onImageSelected(path);
            setState(() {
              selectedImagePath = path;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.8,
            ),
            padding: EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _openImagePicker();
                        },
                        child: _buildImagePicker(),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              "Foto Bukti Pengantaran",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorBlack,
                              ),
                            ),
                            Text(
                              "Unggah foto bukti pesanan telah diterima pembeli dan selesai diantar",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal,
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.textColorBlack,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          key: Key('uploadButton'),
                          color: selectedImagePath != null && !widget.onLoading
                              ? AppColors.primaryColor
                              : Colors.grey,
                          elevation: 0,
                          height: screenSize.height * 0.06,
                          borderRadius: 100,
                          child: widget.onLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Loading",
                                      style: GoogleFonts.poppins(
                                        fontWeight: semibold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )
                              : Text(
                                  "Unggah",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textColorwhite,
                                  ),
                                ),
                          onPressed: () {
                            if (widget.onLoading) return;
                            if (selectedImagePath == null) {
                              CustomSnackbar.warning(
                                  "Silahkan pilih gambar terlebih dahulu");
                              return;
                            }

                            widget.onFinish();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textColorBlack,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final bool hasImage = selectedImagePath != null;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasImage
              ? Image.file(
                  File(selectedImagePath!),
                  width: 136,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : Container(
                  alignment: Alignment.topCenter,
                  width: 136,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: Image.asset('assets/images/upload-photo.png',
                        width: 40),
                  ),
                ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          left: 8,
          child: Semantics(
            label: 'Pilih Gambar',
            button: true,
            child: GestureDetector(
              key: const Key('pickImage'),
              onTap: () {
                setState(() {
                  if (hasImage) {
                    selectedImagePath = null;
                    widget.onImageSelected(null); // ⬅️ lempar ke parent
                  } else {
                    _openImagePicker();
                  }
                  widget.onImageSelected(
                      selectedImagePath); // ⬅️ lempar ke parent
                });
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(hasImage ? 12 : 8),
                ),
                child: Text(
                  hasImage ? 'Ubah Gambar' : 'Ambil Gambar',
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
