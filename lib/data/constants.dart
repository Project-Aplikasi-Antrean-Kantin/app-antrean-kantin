import 'package:flutter/foundation.dart';

abstract class MasbroConstants {
  // static const String _prodUrl = 'https://foodlabpens.com';
  static const String _prodUrl = 'http://128.199.133.57';
  static const String _devUrl = 'http://128.199.133.57';
  static const String version = '1.1.3';

  static String get baseUrl => kReleaseMode ? _prodUrl : _devUrl;

  static String get url => '$baseUrl/api';
}
