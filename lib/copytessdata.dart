import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<void> copyTessDataToAppDirectory() async {
  Directory appDir = await getApplicationDocumentsDirectory();
  String tessDataDir = '${appDir.path}/tessdata';

  if (!await Directory(tessDataDir).exists()) {
    await Directory(tessDataDir).create(recursive: true);
  }

  List<String> trainedDataFiles = ["eng.traineddata", "OCRB.traineddata"];

  for (String fileName in trainedDataFiles) {
    String assetPath = 'assets/tessdata/$fileName';
    String destPath = '$tessDataDir/$fileName';

    if (!await File(destPath).exists()) {
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes = data.buffer.asUint8List();
      await File(destPath).writeAsBytes(bytes);
    }
  }
}
