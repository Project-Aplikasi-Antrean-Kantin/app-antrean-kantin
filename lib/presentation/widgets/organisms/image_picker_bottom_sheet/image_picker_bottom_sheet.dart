import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/organisms/image_picker_bottom_sheet/widgets/option_item.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(String?) onImageSelected;
  final String titleBottomSheet;
  const ImagePickerBottomSheet(
      {super.key,
      required this.onImageSelected,
      required this.titleBottomSheet});

  Future<String?> _processImage(String path) async {
    final tempDir = await getTemporaryDirectory();
    final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempPath = '${tempDir.path}/$tempFileName';

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      path,
      tempPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );

    return compressedImage?.path;
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      final result = await _processImage(picked.path);
      onImageSelected(result);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  titleBottomSheet,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OptionItem(
                      icon: HugeIcons.strokeRoundedCamera02,
                      text: 'Kamera',
                      onTap: () => _pickImage(context, ImageSource.camera),
                    ),
                    OptionItem(
                      icon: HugeIcons.strokeRoundedImage02,
                      text: 'Galeri',
                      onTap: () => _pickImage(context, ImageSource.gallery),
                    ),
                    OptionItem(
                        icon: HugeIcons.strokeRoundedDelete02,
                        text: 'Hapus',
                        onTap: () => onImageSelected(null)),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
