import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/vn_pay/res_status.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class StatusPaymentScreen extends StatelessWidget {
  final IconData icon;
  final String statusLabel;
  ResStatusVnPayModel? resStatusVnPayModel;
  StatusPaymentScreen({
    Key? key,
    required this.icon,
    required this.statusLabel,
    required this.resStatusVnPayModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        title: TextApp(
          text: "Trạng thái giao dịch",
          fontsize: 20.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100.sp,
              color: statusLabel == "Thành công"
                  ? Theme.of(context).colorScheme.primary
                  : Colors.red,
            ),
            SizedBox(height: 20.h),
            Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextApp(
                  text: "Mã giao dịch: ",
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10.w,
                ),
                TextApp(
                  text: resStatusVnPayModel?.data.recharge.code ?? '',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextApp(
                  text: "Số tiền: ",
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10.w,
                ),
                TextApp(
                  text: resStatusVnPayModel?.data.recharge.amount.toString() ??
                      '',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextApp(
                  text: "Phương thức: ",
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10.w,
                ),
                TextApp(
                  text: resStatusVnPayModel?.data.recharge.typeLabel ?? '',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
