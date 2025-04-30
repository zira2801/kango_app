import 'dart:developer';

import 'package:scan_barcode_app/ui/utils/storage.dart';

class ApiUtils {
  static Map<String, String> getHeaders({bool? isNeedToken}) {
    final String? token = StorageUtils.instance.getString(key: 'token');
    log("TOKEN: $token");
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && isNeedToken == true) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
