import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:flutter/widgets.dart'; // Penting untuk decodeImageFromList

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;

  ImageCacheManager._internal();

  final _memoryCache = HashMap<String, File>();

  Future<String> _getFilePath(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = md5.convert(utf8.encode(url)).toString();
    return '${dir.path}/$filename';
  }

  Future<File?> getLocalImage(String url) async {
    if (_memoryCache.containsKey(url)) {
      return _memoryCache[url];
    }

    final path = await _getFilePath(url);
    final file = File(path);

    if (await file.exists()) {
      try {
        final bytes = await file.readAsBytes();
        await decodeImageFromList(bytes); // Validasi file corrupt atau tidak
        _memoryCache[url] = file;
        return file;
      } catch (e) {
        await file.delete();
        return null;
      }
    }
    return null;
  }

  Future<File> downloadAndSaveImage(String url) async {
    final path = await _getFilePath(url);

    final response =
        await http.get(Uri.parse('${MasbroConstants.baseUrl}$url'));

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.startsWith('image/')) {
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);

        try {
          // Validasi ulang hasil download, biar gak nyimpan file aneh
          await decodeImageFromList(response.bodyBytes);
          _memoryCache[url] = file;
          return file;
        } catch (e) {
          await file.delete();
          throw Exception("File corrupt setelah di-download.");
        }
      } else {
        throw Exception(
            "Downloaded file is not an image (content-type: $contentType)");
      }
    } else {
      throw Exception(
          "Failed to download image. Status: ${response.statusCode}");
    }
  }

  Future<File> getOrDownloadImage(String url) async {
    final existing = await getLocalImage(url);
    if (existing != null) {
      return existing;
    }
    return await downloadAndSaveImage(url);
  }
}
