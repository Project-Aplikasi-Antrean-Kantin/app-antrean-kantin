import 'dart:typed_data';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class QrisImageSaver {
  static Future<void> save(String url, int secondsRemaining) async {
    if (secondsRemaining <= 0) {
      Fluttertoast.showToast(msg: 'Waktu telah habis, silahkan ganti nominal');
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await SaverGallery.saveImage(
          Uint8List.fromList(response.bodyBytes),
          quality: 60,
          fileName: 'foodlab_qris_${DateTime.now().millisecondsSinceEpoch}',
          androidRelativePath: 'Pictures/foodlab/images',
          skipIfExists: false,
        );
        Fluttertoast.showToast(
          msg: 'Berhasil disimpan',
          backgroundColor: AppColors.successColor,
          textColor: AppColors.whiteColor,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Gagal disimpan, silahkan coba lagi',
          backgroundColor: AppColors.errorColor,
          textColor: AppColors.whiteColor,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Terjadi kesalahan: $e',
        backgroundColor: AppColors.errorColor,
        textColor: AppColors.whiteColor,
      );
    }
  }
}
