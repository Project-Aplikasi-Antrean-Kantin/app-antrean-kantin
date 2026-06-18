import 'package:flutter/foundation.dart';

abstract class MasbroConstants {
  // static const String _prodUrl = 'https://foodlabpens.com';
  static const String _prodUrl = 'https://staging.foodlab-dev.online';
  static const String _devUrl = 'https://staging.foodlab-dev.online';
  static const String version = '1.1.4';

  static String get baseUrl => kReleaseMode ? _prodUrl : _devUrl;

  static String get url => '$baseUrl/api';
}
