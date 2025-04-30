import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class DetailsScanedCode extends StatefulWidget {
  final String barCodeScanned;
  const DetailsScanedCode({
    super.key,
    required this.barCodeScanned,
  });

  @override
  State<DetailsScanedCode> createState() => _DetailsScanedCodeState();
}

class _DetailsScanedCodeState extends State<DetailsScanedCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change back button color here
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: TextApp(
          text: "Chi tiết mã đã quét",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextApp(
                    text: "Mã đơn hàng đã quét: ",
                    color: Theme.of(context).colorScheme.onBackground,
                    fontsize: 20.sp,
                  ),
                  TextApp(
                    text: widget.barCodeScanned,
                    color: Theme.of(context).colorScheme.primary,
                    fontsize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(
                    height: 20.h,
                  )
                ],
              )
            ],
          ),
          ButtonApp(
              event: () {
                Navigator.pop(context);
              },
              text: "Scan More",
              colorText: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              outlineColor: Theme.of(context).colorScheme.primary)
        ],
      )),
    );
  }
}
