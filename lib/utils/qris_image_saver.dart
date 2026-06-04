import 'dart:typed_data';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

class QrisImageSaver {
  static Future<void> save(String url, int secondsRemaining) async {
    if (secondsRemaining <= 0) {
      CustomSnackbar.info('Waktu telah habis, silahkan ganti nominal');
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
        CustomSnackbar.success(
          'Berhasil disimpan',
        );
      } else {
        CustomSnackbar.error(
          'Gagal disimpan, silahkan coba lagi',
        );
      }
    } catch (e) {
      CustomSnackbar.error(
        'Terjadi kesalahan: $e',
      );
    }
  }
}
