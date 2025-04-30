import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

class TermsOfService extends StatefulWidget {
  const TermsOfService({super.key});

  @override
  State<TermsOfService> createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService> {
  String htmlData = "";

  Future<void> getListTypeService() async {
    try {
      // Sending the HTTP request
      final response = await http.post(
        Uri.parse('$baseUrl$getHTMLPolicy'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'is_api': true,
        }),
      );

      if (response.statusCode == 200) {
        // Parse response body
        final data = jsonDecode(response.body);

        if (data['status'] == 200) {
          // Check if widget is still mounted before calling setState
          if (mounted) {
            setState(() {
              htmlData = data['data'] ?? ""; // Safely assign HTML data
            });
          }
        } else {
          log("getListTypeService error: status ${data['status']}");
        }
      } else {
        log("HTTP error: ${response.statusCode}"); // Log HTTP error
      }
    } catch (error) {
      log("getListTypeService error: $error"); // Catch and log any errors
    }
  }

  @override
  void initState() {
    super.initState();
    getListTypeService(); // Fetch the HTML content when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        title: TextApp(
          text: "Điều Khoản Của KANGO EXPRESS",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Html(
            data: htmlData, // Pass your HTML data here
            style: {
              "strong": Style(
                backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
              ),
            },
          ),
        ),
      ),
    );
  }
}
