import 'dart:io';
import 'package:flutter/material.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/utils/image_cache_manager.dart';

class ImageByUrl extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageByUrl({
    super.key,
    required this.url,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ImageByUrl> createState() => _ImageByUrlState();
}

class _ImageByUrlState extends State<ImageByUrl> {
  File? imageFile;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      String cleanedUrl = widget.url;
      if (cleanedUrl.startsWith(MasbroConstants.baseUrl)) {
        cleanedUrl = cleanedUrl.replaceFirst(MasbroConstants.baseUrl, '');
      }
      final file = await ImageCacheManager().getOrDownloadImage(cleanedUrl);
      if (mounted) {
        setState(() {
          imageFile = file;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return widget.placeholder ??
          SizedBox(
            width: widget.width,
            height: widget.height,
          );
    }

    if (isError || imageFile == null) {
      return widget.errorWidget ??
          Image.asset(
            'assets/images/dummy.jpeg',
            fit: BoxFit.cover,
            height: widget.width,
            width: double.infinity,
          );
    }

    return Image.file(
      imageFile!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
