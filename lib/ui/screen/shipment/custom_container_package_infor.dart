import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class CustomContainerPakageInfor extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? expandContent;
  const CustomContainerPakageInfor(
      {super.key,
      required this.title,
      required this.content,
      this.expandContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 1.sw,
            height: 30.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.r),
                  topRight: Radius.circular(15.r)),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outlined,
                  size: 18.sp,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10.w,
                ),
                TextApp(
                  text: title,
                  color: Colors.white,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.bold,
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(10.w), child: content),
          expandContent ?? Container()
        ],
      ),
    );
  }
}
