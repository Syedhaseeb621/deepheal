import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Automatically switches between 10.0.2.2 (Android) and 127.0.0.1 (Web/iOS)
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  static String get chatEndpoint => "$baseUrl/chat";
}
