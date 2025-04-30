import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 300.w,
            height: 300.w,
            child: Lottie.asset('assets/lottie/no_internet.json'),
          ),
          SizedBox(
            height: 50.h,
          ),
          TextApp(
            text: "Vui lòng kiểm tra kết nối mạng",
            fontsize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    ));
  }
}
