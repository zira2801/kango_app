import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class StatusBox extends StatelessWidget {
  final String textStatus;
  final Color colorBoxStatus;
  final Icon icon;
  const StatusBox({
    super.key,
    required this.textStatus,
    required this.colorBoxStatus,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 20.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: colorBoxStatus,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          SizedBox(
            width: 3.w,
          ),
          TextApp(
            text: textStatus,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            maxLines: 2,
          )
        ],
      ),
    );
  }
}
