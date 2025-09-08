import 'package:flutter/foundation.dart';

abstract class MasbroConstants {
  static const String _prodUrl = 'https://foodlabpens.com';
  static const String _devUrl = 'http://128.199.133.57';

  static String get baseUrl => kReleaseMode ? _prodUrl : _devUrl;

  static String get url => '$baseUrl/api';
}
