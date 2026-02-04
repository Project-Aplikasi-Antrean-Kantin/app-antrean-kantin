import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  String? selectedImagePath;

  /// Fungsi cek ukuran file dalam KB
  Future<int> _getImageSize(String path) async {
    final file = File(path);
    return (await file.length() / 1024).round();
  }

  Future<void> _getImageFromGallery(BuildContext context) async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempPath = '${tempDir.path}/$tempFileName';

      try {
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          pickedImage.path,
          tempPath,
          quality: 70,
          minWidth: 1024,
          minHeight: 1024,
        );
        if (compressedImage != null) {
          selectedImagePath = compressedImage.path;
          int imageSizeKB = await _getImageSize(selectedImagePath!);
          if (imageSizeKB > 2048) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: "Peringatan!",
                  message:
                      "Gambar yang kamu pilih lebih dari 2MB bahkan setelah kompresi.",
                  showCancelButton: false,
                );
              },
            );
            selectedImagePath = null;
          }
          Navigator.pop(context);
          widget.onImageSelected(selectedImagePath); // ⬅️ lempar ke parent

          setState(() {});
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: "Gagal!",
                message: "Gagal mengompresi gambar. Silakan coba lagi.",
                showCancelButton: false,
              );
            },
          );
        }
      } catch (e) {
        debugPrint('Compression error: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: "Error!",
              message: "Terjadi kesalahan saat mengompresi gambar: $e",
              showCancelButton: false,
            );
          },
        );
      }
    }
  }

  /// Fungsi ambil foto dari kamera + kompres
  Future<void> _getImageFromCamera(BuildContext context) async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempPath = '${tempDir.path}/$tempFileName';

      try {
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          pickedImage.path,
          tempPath,
          quality: 70,
          minWidth: 1024,
          minHeight: 1024,
        );
        if (compressedImage != null) {
          selectedImagePath = compressedImage.path;
          int imageSizeKB = await _getImageSize(selectedImagePath!);
          if (imageSizeKB > 2048) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  title: "Peringatan!",
                  message:
                      "Gambar yang kamu ambil lebih dari 2MB bahkan setelah kompresi.",
                  showCancelButton: false,
                );
              },
            );
            selectedImagePath = null;
          }
          Navigator.pop(context);
          widget.onImageSelected(selectedImagePath); // ⬅️ lempar ke parent

          setState(() {});
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: "Gagal!",
                message: "Gagal mengompresi gambar. Silakan coba lagi.",
                showCancelButton: false,
              );
            },
          );
        }
      } catch (e) {
        debugPrint('Compression error: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: "Error!",
              message: "Terjadi kesalahan saat mengompresi gambar: $e",
              showCancelButton: false,
            );
          },
        );
      }
    }
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
                          _buildBottomSheetProfile(context);
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
                              Fluttertoast.showToast(
                                  msg: "Gambar belum diunggah");
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
                    _buildBottomSheetProfile(context);
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

  Future<void> _buildBottomSheetProfile(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor400,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                  child: Column(
                    spacing: 16,
                    children: [
                      Text(
                        'Gambar Pengantaran',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            label: 'Kamera',
                            button: true,
                            child: GestureDetector(
                              key: const Key('camera'),
                              onTap: () {
                                _getImageFromCamera(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  border: BoxBorder.all(
                                      color: AppColors.blackColor100, width: 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedCamera02,
                                      color: AppColors.primaryColor,
                                    ),
                                    Text(
                                      'Kamera',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Galeri',
                            button: true,
                            child: GestureDetector(
                              key: const Key('gallery'),
                              onTap: () {
                                _getImageFromGallery(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  border: BoxBorder.all(
                                      color: AppColors.blackColor100, width: 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedImage02,
                                      color: AppColors.primaryColor,
                                    ),
                                    Text(
                                      'Galeri',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (selectedImagePath != null) {
                                selectedImagePath = null;
                                widget.onImageSelected(
                                    null); // ⬅️ lempar ke parent

                                Navigator.pop(context);
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                border: BoxBorder.all(
                                    color: AppColors.blackColor100, width: 1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedDelete02,
                                    color: AppColors.primaryColor,
                                  ),
                                  Text(
                                    'Hapus',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
          );
        });
  }
}
