import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TestScanImageToText extends StatefulWidget {
  const TestScanImageToText({super.key});

  @override
  State<TestScanImageToText> createState() => _TestScanImageToTextState();
}

class _TestScanImageToTextState extends State<TestScanImageToText> {
  final ImagePicker _picker = ImagePicker();
  String scannedText = '';
  bool isScanning = false;
  File? _image;

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        scannedText = '';
        isScanning = true;
      });
      _scanTextFromImage();
    }
  }

  // Function to scan text from the selected image
  Future<void> _scanTextFromImage() async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final inputImage = InputImage.fromFile(_image!);
    // final textRecognizer = GoogleMlKit.vision.textRecognizer();
    // final RecognizedText recognizedText =
    //     await textRecognizer.processImage(inputImage);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String extractedText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        extractedText += line.text + '\n';
      }
    }

    setState(() {
      scannedText = extractedText.isNotEmpty ? extractedText : 'No text found';
      isScanning = false;
    });

    textRecognizer
        .close(); // Don't forget to close the recognizer to release resources
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Scanner'),
      ),
      body: Center(
        child: isScanning
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image != null
                      ? Image.file(_image!, width: 300, height: 300)
                      : Icon(Icons.image, size: 150),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera),
                    label: Text('Take a Picture'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Choose from Gallery'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    scannedText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
